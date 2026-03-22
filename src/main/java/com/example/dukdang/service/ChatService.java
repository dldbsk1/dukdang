package com.example.dukdang.service;

import com.example.dukdang.dto.MessageRequest;
import com.google.cloud.firestore.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

/**
 * [클래스 목적] Firestore DB와 연동하여 채팅방 목록 병합 조회, 상대방 정보 매핑, 메시지 내역 조회, 메시지 저장 및 상태 갱신 등 채팅 도메인의 핵심 비즈니스 로직을 처리하는 서비스 계층입니다.
 */
@Service // 스프링 컨테이너에 서비스 빈(Bean)으로 등록하여 비즈니스 로직을 수행하는 계층임을 명시합니다.
@RequiredArgsConstructor // final로 선언된 Firestore 필드에 대해 생성자를 자동 생성하여 의존성을 주입받습니다.
public class ChatService {

    // Google Cloud Firestore 연동을 위한 데이터베이스 클라이언트 객체입니다.
    private final Firestore db;

    /**
     * [메서드 목적] 특정 사용자가 구매자 또는 판매자로 참여 중인 모든 채팅방 데이터를 Firestore에서 조회하여 하나의 리스트로 병합 반환합니다.
     */
    public List<Map<String, Object>> getChatList(String userId) throws Exception {
        // [로직 이유] Firestore는 단일 쿼리에서 서로 다른 필드에 대한 'OR' 연산을 완벽하게 지원하지 않으므로, 두 개의 독립적인 쿼리를 실행합니다.
        // 1. 해당 사용자가 'buyerId' 필드와 일치하는(구매자인) 채팅방 문서를 조회합니다.
        var buyerQuery = db.collection("chatRooms").whereEqualTo("buyerId", userId).get().get();
        // 2. 해당 사용자가 'sellerId' 필드와 일치하는(판매자인) 채팅방 문서를 조회합니다.
        var sellerQuery = db.collection("chatRooms").whereEqualTo("sellerId", userId).get().get();

        // 두 쿼리 결과를 합칠 반환용 리스트를 초기화합니다.
        List<Map<String, Object>> allRooms = new ArrayList<>();

        // 3. 내부 헬퍼 메서드를 호출하여 조회된 각 쿼리의 문서 데이터를 리스트에 병합하고, 상대방의 이름 데이터를 추가 매핑합니다.
        processRooms(buyerQuery, userId, allRooms);
        processRooms(sellerQuery, userId, allRooms);

        return allRooms;
    }

    /**
     * [메서드 목적] 채팅방 데이터 리스트를 순회하며 상대방의 ID를 추출하고, 'users' 컬렉션을 추가 조회하여 상대방의 이름을 결과 데이터에 맵핑합니다.
     */
    private void processRooms(QuerySnapshot query, String currentUserId, List<Map<String, Object>> result) throws Exception {
        for (var doc : query.getDocuments()) {
            Map<String, Object> roomData = new HashMap<>(doc.getData());

            // 삼항 연산자를 사용하여 현재 사용자의 ID가 buyerId인지 확인하고, 상대방의 ID(opponentId)를 식별합니다.
            String opponentId = currentUserId.equals(roomData.get("buyerId"))
                    ? (String) roomData.get("sellerId")
                    : (String) roomData.get("buyerId");

            // 식별된 상대방 ID를 기반으로 'users' 컬렉션의 해당 사용자 문서를 조회(Join 역할)합니다.
            var userDoc = db.collection("users").document(opponentId).get().get();
            // 상대방 문서가 존재하면 'name' 필드를 가져오고, 없으면 기본 대체 문자열을 삽입하여 클라이언트에 렌더링용 데이터를 제공합니다.
            roomData.put("opponentName", userDoc.exists() ? userDoc.getString("name") : "알 수 없는 사용자");

            result.add(roomData);
        }
    }

    /**
     * [메서드 목적] 특정 채팅방 문서의 하위 컬렉션인 'messages'에서 전체 대화 내역을 조회하고 오름차순 정렬하여 반환합니다.
     */
    public List<Map<String, Object>> getMessages(String roomId) throws Exception {
        var messages = db.collection("chatRooms").document(roomId)
                .collection("messages") // 채팅방 문서(Document) 하위에 종속된 메시지 컬렉션(Subcollection)에 접근합니다.
                .orderBy("sentAt", Query.Direction.ASCENDING) // 메시지가 생성된 시간(sentAt)을 기준으로 오름차순(과거 -> 최신) 정렬합니다.
                .get().get();

        // 쿼리 결과(QuerySnapshot)를 순회하며 순수 데이터(Map)만 추출하여 리스트로 반환합니다.
        List<Map<String, Object>> result = new ArrayList<>();
        messages.getDocuments().forEach(d -> result.add(d.getData()));
        return result;
    }

    /**
     * [메서드 목적] 새로운 메시지 데이터를 Firestore에 삽입하고, 채팅방 목록 조회 성능 최적화를 위해 부모 채팅방 문서의 메타데이터(최근 메시지)를 업데이트합니다.
     */
    public void sendMessage(MessageRequest request) throws Exception {
        var roomRef = db.collection("chatRooms").document(request.getRoomId());

        // 1. 하위 컬렉션에 삽입할 개별 메시지 페이로드(Payload)를 구성합니다.
        Map<String, Object> msg = new HashMap<>();
        msg.put("senderId", request.getSenderId());
        msg.put("content", request.getContent());
        // FieldValue.serverTimestamp()를 사용하여 클라이언트 간 기기 시간 편차를 무시하고 DB 서버의 절대 시간을 기록합니다.
        msg.put("sentAt", FieldValue.serverTimestamp());

        // 2. 구성된 메시지 객체를 해당 방의 'messages' 하위 컬렉션에 문서로 추가(add)합니다.
        roomRef.collection("messages").add(msg);

        // 3. [데이터 역정규화 로직] 채팅 목록 조회 시마다 매번 내부 messages 컬렉션을 탐색하는 오버헤드를 막기 위해,
        // 부모 문서(chatRooms)에 최신 메시지 내용과 시간을 직접 갱신(update)합니다.
        Map<String, Object> update = new HashMap<>();
        update.put("lastMessage", request.getContent());
        update.put("lastTimestamp", FieldValue.serverTimestamp());
        roomRef.update(update);
    }
}