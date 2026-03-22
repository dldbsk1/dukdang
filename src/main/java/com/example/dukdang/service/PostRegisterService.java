package com.example.dukdang.service;

import com.example.dukdang.dto.PostRequest;
import com.google.cloud.firestore.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

/**
 * [클래스 목적] 클라이언트로부터 전달받은 데이터를 가공하여 Firestore DB에 새로운 판매 게시글 문서(Document)로 생성 및 저장하는 비즈니스 로직을 전담하는 서비스 계층입니다.
 */
@Service // 스프링 컨테이너에 서비스 빈(Bean)으로 등록하여 핵심 비즈니스 로직을 수행하는 계층임을 명시합니다.
@RequiredArgsConstructor // final로 선언된 Firestore 필드에 대해 생성자를 자동 생성하여 의존성을 주입받습니다.
public class PostRegisterService {

    // Google Cloud Firestore 연동을 위한 데이터베이스 클라이언트 객체입니다.
    private final Firestore db;

    /**
     * [메서드 목적] 새로운 판매 게시글 데이터를 Firestore의 'posts' 컬렉션에 등록하고, 자동 생성된 문서 ID를 반환합니다.
     */
    public String registerPost(PostRequest request) throws Exception {
        // 1. 'posts' 컬렉션 내에 고유한 난수 ID를 가진 새로운 문서 참조(Document Reference)를 생성합니다.
        var posts = db.collection("posts").document();

        // 2. DB 문서에 삽입할 데이터 페이로드(Payload)를 담을 Map 객체를 초기화합니다.
        Map<String, Object> data = new HashMap<>();

        // 3. Firestore가 자동 생성한 문서 ID를 추출하여 식별자 데이터('postId')로도 저장합니다.
        data.put("postId", posts.getId());

        // 4. 클라이언트가 DTO(PostRequest)를 통해 전송한 요청 데이터들을 Map 객체에 바인딩합니다.
        data.put("title", request.getTitle());
        data.put("content", request.getContent());
        data.put("price", request.getPrice());
        data.put("originalPrice", request.getOriginalPrice());
        data.put("conditionScore", request.getConditionScore());
        data.put("imageUrls", request.getImageUrls());
        data.put("sellerId", request.getSellerId());
        data.put("category", request.getCategory());

        // 5. 비즈니스 요구사항에 따라 서버 사이드에서 초기 상태값 및 메타데이터를 직접 주입합니다.
        data.put("status", "SALE");      // 게시글 초기 판매 상태
        data.put("viewCount", 0);        // 누적 조회수 초기화
        data.put("likeCount", 0);        // 누적 찜 횟수 초기화
        // 클라이언트 기기 시간이 아닌 DB 서버의 신뢰할 수 있는 절대 시간을 기록합니다.
        data.put("createdAt", FieldValue.serverTimestamp());

        // 6. 매핑이 완료된 데이터(Map)를 앞서 생성한 문서 참조 위치에 저장(set)합니다.
        posts.set(data).get();

        // 7. 성공적으로 저장이 완료된 게시글의 고유 식별자(ID)를 클라이언트에게 반환합니다.
        return posts.getId();
    }
}