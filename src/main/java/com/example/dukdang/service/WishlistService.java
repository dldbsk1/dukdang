package com.example.dukdang.service;

import com.google.cloud.firestore.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

/**
 * [클래스 목적] 특정 사용자가 '찜'한 게시글들을 추적하여 실제 게시글 데이터를 모아 제공하는 비즈니스 로직을 수행하는 서비스 계층입니다.
 */
@Service // 스프링 컨테이너에 서비스 빈(Bean)으로 등록하여 비즈니스 로직 계층임을 명시합니다.
@RequiredArgsConstructor // final로 선언된 Firestore 필드에 대해 생성자를 자동 생성하여 의존성을 주입받습니다.
public class WishlistService {

    // Firestore 데이터베이스 접근을 위한 클라이언트 객체입니다.
    private final Firestore db;

    /**
     * [메서드 목적] 사용자의 아이디를 조건으로 찜 목록을 조회하고, 연결된 게시글 ID를 통해 실제 게시글 상세 정보를 리스트 형태로 반환합니다.
     */
    public List<Map<String, Object>> getMyWishlist(String userId) throws Exception {
        // 1. 'wishlist' 컬렉션에서 'userId' 필드가 인자로 받은 값과 일치하는 모든 문서(찜 기록)를 쿼리합니다.
        var wishQuery = db.collection("wishlist").whereEqualTo("userId", userId).get().get();

        // 최종적으로 게시글 상세 정보들을 담아 반환할 리스트를 초기화합니다.
        List<Map<String, Object>> wishPosts = new ArrayList<>();

        // 2. 조회된 찜 기록 문서(QueryDocumentSnapshot)들을 하나씩 순회합니다.
        for (var doc : wishQuery.getDocuments()) {
            // 3. 찜 문서 내에 저장된 게시글의 고유 아이디('postId')를 추출합니다.
            String postId = doc.getString("postId");

            // 4. 추출한 postId를 사용하여 'posts' 컬렉션에서 실제 판매 게시글의 상세 데이터를 직접 조회(Fetch)합니다.
            // 이는 RDBMS의 Join 연산을 NoSQL 환경에서 애플리케이션 레벨의 참조 조회를 통해 구현한 방식입니다.
            var postDoc = db.collection("posts").document(postId).get().get();

            // 5. 원본 게시글이 삭제되지 않고 존재하는 경우에만 해당 문서의 전체 데이터를 결과 리스트에 추가합니다.
            if (postDoc.exists()) {
                wishPosts.add(postDoc.getData());
            }
        }

        // 6. 사용자가 찜한 모든 게시글의 데이터 꾸러미를 반환합니다.
        return wishPosts;
    }
}