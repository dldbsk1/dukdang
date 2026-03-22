package com.example.dukdang.service;

import com.google.cloud.firestore.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

/**
 * [클래스 목적] 단일 게시글의 상세 조회, 조회수 증가, 찜(Wishlist) 상태 확인 및 토글, 판매 상태 업데이트 등 게시글 상세 도메인과 관련된 핵심 비즈니스 로직을 처리하는 서비스 계층입니다.
 */
@Service // 스프링 컨테이너에 빈(Bean)으로 등록되어 비즈니스 로직을 수행하는 계층임을 명시합니다.
@RequiredArgsConstructor // final로 선언된 Firestore 필드에 대해 생성자를 자동 생성하여 의존성을 주입받습니다.
public class PostDetailService {

    // Google Cloud Firestore 연동을 위한 데이터베이스 클라이언트 객체입니다.
    private final Firestore db;

    /**
     * [메서드 목적] 특정 게시글의 상세 데이터를 조회하고 조회수를 1 증가시키며, 해당 사용자의 찜 여부를 확인하여 결과 데이터에 병합 반환합니다.
     */
    public Map<String, Object> getPostDetail(String postId, String userId) throws Exception {
        // 1. 'posts' 컬렉션에서 클라이언트가 요청한 postId에 해당하는 문서 참조(Reference)를 가져옵니다.
        var postRef = db.collection("posts").document(postId);

        // 2. [조회수 증가] FieldValue.increment()를 사용하여 동시성 문제 없이 서버 사이드에서 안전하게 'viewCount' 값을 1 증가시킵니다.
        postRef.update("viewCount", FieldValue.increment(1));

        // 3. 업데이트된 문서의 실제 데이터를 가져옵니다. 문서가 존재하지 않으면 null을 반환합니다.
        var postDoc = postRef.get().get();
        if (!postDoc.exists()) return null;

        // 문서의 데이터를 Map 형태로 추출합니다.
        Map<String, Object> data = postDoc.getData();

        // 4. [찜 여부 확인] 복합키(userId_postId)를 생성하여 'wishlist' 컬렉션에 해당 문서가 존재하는지(찜했는지) 확인합니다.
        String wishId = userId + "_" + postId;
        boolean isLiked = db.collection("wishlist").document(wishId).get().get().exists();

        // 5. 확인된 찜 여부 상태(boolean)를 응답 데이터에 'isLiked'라는 키로 추가하여 클라이언트에게 최종 반환합니다.
        data.put("isLiked", isLiked);

        return data;
    }

    /**
     * [메서드 목적] 특정 사용자의 특정 게시글에 대한 찜 상태를 토글(추가/취소)하고, 해당 게시글의 찜 횟수(likeCount) 메타데이터를 동기화합니다.
     */
    public boolean toggleWish(String userId, String postId) throws Exception {
        // 찜 문서의 고유 ID를 생성합니다.
        String docId = userId + "_" + postId;
        var wishRef = db.collection("wishlist").document(docId);
        var postRef = db.collection("posts").document(postId);

        // 1. 이미 찜 목록에 문서가 존재하는 경우 (찜 취소 로직)
        if (wishRef.get().get().exists()) {
            // 찜 문서를 삭제합니다.
            wishRef.delete();
            // 원본 게시글 문서의 'likeCount'를 1 감소시킵니다.
            postRef.update("likeCount", FieldValue.increment(-1));
            // 취소되었음을 나타내는 false를 반환합니다.
            return false;
        } else {
            // 2. 찜 목록에 문서가 존재하지 않는 경우 (찜 추가 로직)
            // 찜 문서를 새로 생성하고 userId와 postId 정보를 저장합니다.
            wishRef.set(Map.of("userId", userId, "postId", postId));
            // 원본 게시글 문서의 'likeCount'를 1 증가시킵니다.
            postRef.update("likeCount", FieldValue.increment(1));
            // 추가되었음을 나타내는 true를 반환합니다.
            return true;
        }
    }

    /**
     * [메서드 목적] 특정 게시글의 판매 상태(예: SALE, RESERVED, SOLD)를 클라이언트로부터 전달받은 새로운 상태 값으로 덮어씁니다.
     */
    public void updateStatus(String postId, String newStatus) throws Exception {
        // 'posts' 컬렉션에서 해당 postId 문서를 찾아 'status' 필드 값만 새 상태 값으로 즉시 업데이트합니다.
        db.collection("posts").document(postId).update("status", newStatus);
    }
}