package com.example.dukdang.service;

import com.example.dukdang.dto.MessageRequest;
import com.google.cloud.firestore.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final Firestore db;

    /**
     * [함수 목적] 사용자가 참여 중인 모든 채팅방 목록을 가져옵니다.
     * [이유] Firestore는 'OR' 쿼리가 까다롭기 때문에, 내가 '구매자'인 경우와 '판매자'인 경우를
     * 각각 조회해서 하나로 합치는 방식을 사용했습니다.
     */
    public List<Map<String, Object>> getChatList(String userId) throws Exception {
        // 1. 내가 구매자로 등록된 방들 찾기
        var buyerQuery = db.collection("chatRooms").whereEqualTo("buyerId", userId).get().get();
        // 2. 내가 판매자로 등록된 방들 찾기
        var sellerQuery = db.collection("chatRooms").whereEqualTo("sellerId", userId).get().get();

        List<Map<String, Object>> allRooms = new ArrayList<>();

        // 3. 찾은 방들을 리스트에 넣으면서 상대방 정보를 채워넣는 공통 작업 수행
        processRooms(buyerQuery, userId, allRooms);
        processRooms(sellerQuery, userId, allRooms);

        return allRooms;
    }

    /**
     * [함수 목적] 쿼리 결과로 나온 방 목록에 '상대방 이름'을 추가합니다.
     * [이유] 'chatRooms' 컬렉션에는 ID만 저장되어 있기 때문에, 실제 화면에 보여줄
     * '이름'은 'users' 컬렉션에서 다시 가져와야 사용자에게 친절한 UI를 제공할 수 있습니다.
     */
    private void processRooms(QuerySnapshot query, String currentUserId, List<Map<String, Object>> result) throws Exception {
        for (var doc : query.getDocuments()) {
            Map<String, Object> roomData = new HashMap<>(doc.getData());

            // [로직] 내 ID가 buyerId와 같다면 상대방은 sellerId이고, 그 반대면 buyerId가 상대방입니다.
            String opponentId = currentUserId.equals(roomData.get("buyerId"))
                    ? (String) roomData.get("sellerId")
                    : (String) roomData.get("buyerId");

            // [중요] 상대방의 상세 정보(이름 등)를 가져오기 위해 users 컬렉션을 한 번 더 조회합니다.
            var userDoc = db.collection("users").document(opponentId).get().get();
            roomData.put("opponentName", userDoc.exists() ? userDoc.getString("name") : "알 수 없는 사용자");

            result.add(roomData);
        }
    }

    /**
     * [함수 목적] 특정 채팅방 안에서 오고 간 메시지 내역을 전부 가져옵니다.
     * [이유] 'sentAt'을 기준으로 오름차순(ASCENDING) 정렬하여 대화가 흐름에 맞게 보이도록 합니다.
     */
    public List<Map<String, Object>> getMessages(String roomId) throws Exception {
        var messages = db.collection("chatRooms").document(roomId)
                .collection("messages") // [구조] 방 문서 안에 'messages'라는 하위 컬렉션을 사용했습니다.
                .orderBy("sentAt", Query.Direction.ASCENDING)
                .get().get();

        List<Map<String, Object>> result = new ArrayList<>();
        messages.getDocuments().forEach(d -> result.add(d.getData()));
        return result;
    }

    /**
     * [함수 목적] 새 메시지를 저장하고, 채팅 목록에 보여줄 '마지막 메시지' 정보를 갱신합니다.
     * [이유] 사용자가 채팅 목록만 봤을 때도 최신 메시지가 뭔지 바로 알 수 있게 하기 위해서입니다.
     */
    public void sendMessage(MessageRequest request) throws Exception {
        var roomRef = db.collection("chatRooms").document(request.getRoomId());

        // 1. 실제 메시지 데이터 생성 (누가, 무엇을, 언제)
        Map<String, Object> msg = new HashMap<>();
        msg.put("senderId", request.getSenderId());
        msg.put("content", request.getContent());
        msg.put("sentAt", FieldValue.serverTimestamp()); // [팁] 서버 시간을 사용해야 기기별 시간 차이를 방지합니다.

        // 2. 해당 방의 하위 컬렉션인 'messages'에 추가
        roomRef.collection("messages").add(msg);

        // 3. [최적화] 방 정보(부모 문서) 업데이트
        // 목록 화면에서 매번 모든 메시지를 뒤질 수 없으므로, 마지막 메시지와 시간을 방 정보에 '미리 써두는' 방식입니다.
        Map<String, Object> update = new HashMap<>();
        update.put("lastMessage", request.getContent());
        update.put("lastTimestamp", FieldValue.serverTimestamp());
        roomRef.update(update);
    }
}
