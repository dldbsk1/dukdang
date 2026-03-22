package com.example.dukdang.service;

import com.google.cloud.firestore.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;

/**
 * [클래스 목적] Firestore DB와 연동하여 카테고리 필터링 및 키워드 검색 조건에 맞는 게시글 목록을 동적으로 구성하여 조회하는 비즈니스 로직을 전담하는 서비스 계층입니다.
 */
@Service // 스프링 컨테이너에 서비스 빈(Bean)으로 등록하여 핵심 비즈니스 로직을 수행하는 계층임을 명시합니다.
@RequiredArgsConstructor // final로 선언된 Firestore 필드에 대해 생성자를 자동 생성하여 의존성을 주입받습니다.
public class PostListService {

    // Google Cloud Firestore 연동을 위한 데이터베이스 클라이언트 객체입니다.
    private final Firestore db;

    /**
     * [메서드 목적] 클라이언트로부터 전달받은 카테고리와 검색어(키워드) 파라미터의 유무에 따라 Firestore 쿼리를 동적으로 조립하고 실행하여 결과 목록을 반환합니다.
     */
    public List<Map<String, Object>> getPosts(String category, String keyword) throws Exception {
        // 1. 'posts' 컬렉션의 전체 문서를 대상으로 하는 기본 쿼리(Query) 객체를 초기화합니다.
        Query query = db.collection("posts");

        // 2. [카테고리 조건] 파라미터로 전달된 카테고리 값이 존재할 경우, DB의 'category' 필드와 값이 정확히 일치하는 문서만 필터링하도록 쿼리를 추가합니다.
        if (category != null && !category.isEmpty()) {
            query = query.whereEqualTo("category", category);
        }

        // 3. [검색 및 정렬 조건]
        if (keyword != null && !keyword.isEmpty()) {
            // 키워드가 존재할 경우, 'title' 필드를 기준으로 해당 키워드가 포함된 문서를 찾습니다.
            // '\uf8ff'는 유니코드 상 매우 큰 값이므로, startAt과 endAt을 결합하여 RDBMS의 LIKE '키워드%'와 같은 접두사 범위 검색(Prefix Search)을 구현합니다.
            query = query.orderBy("title").startAt(keyword).endAt(keyword + "\uf8ff");
        } else {
            // 키워드가 없을 경우, 기본 상태로 간주하여 작성 시간('createdAt') 필드를 기준으로 내림차순(최신순) 정렬 조건을 쿼리에 추가합니다.
            query = query.orderBy("createdAt", Query.Direction.DESCENDING);
        }

        // 4. 조립이 완료된 동적 쿼리를 실행하여 결과 데이터(QuerySnapshot)를 동기적으로 가져옵니다.
        var result = query.get().get();
        List<Map<String, Object>> postList = new ArrayList<>();

        // 5. 반환된 문서(Document) 리스트를 순회하며 순수 데이터(Map<String, Object>)만 추출하여 새로운 리스트에 담아 최종 반환합니다.
        result.getDocuments().forEach(doc -> postList.add(doc.getData()));
        return postList;
    }
}