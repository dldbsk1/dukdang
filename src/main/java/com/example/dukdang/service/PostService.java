package com.example.dukdang.service;

import com.example.dukdang.dto.PostRequest;
import com.google.cloud.firestore.FieldValue;
import com.google.cloud.firestore.Firestore;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor // [이유] final로 선언된 Firestore db 객체를 스프링이 자동으로 넣어주게(주입) 합니다.
public class PostService {
    private final Firestore db;

    /**
     * [함수 목적] 사용자가 작성한 게시글 데이터를 Firestore의 'posts' 컬렉션에 새 문서로 저장합니다.
     * [리턴 값] 생성된 게시글의 고유 ID (postId)를 반환하여, 이후 프론트엔드에서 해당 글 상세페이지로 이동할 수 있게 돕습니다.
     */
    public String registerPost(PostRequest request) throws Exception {

        // 1. [이유] 'posts' 컬렉션에 ID가 자동 생성된 새로운 문서 참조(Reference)를 만듭니다.
        // 아직 DB에 저장된 건 아니고, "이런 자리를 만들겠다"는 선언입니다.
        var posts = db.collection("posts").document();

        // 2. [이유] Firestore는 데이터를 Map 형태(Key-Value)로 저장해야 합니다.
        // DTO(PostRequest)에 담긴 데이터를 꺼내서 DB 저장용 Map에 하나씩 옮겨 담는 과정입니다.
        Map<String, Object> data = new HashMap<>();

        // [이유] 나중에 게시글을 수정하거나 삭제할 때 이 ID가 꼭 필요하므로 문서 안에 함께 저장해둡니다.
        data.put("postId", posts.getId());
        data.put("title", request.getTitle());
        data.put("content", request.getContent());
        data.put("price", request.getPrice());
        data.put("originalPrice", request.getOriginalPrice());

        // [이유] 상품 상태 점수(1~5점)나 이미지 URL 리스트 등 복잡한 데이터도 Map에 담아 한꺼번에 보냅니다.
        data.put("conditionScore", request.getConditionScore());
        data.put("imageUrls", request.getImageUrls());
        data.put("sellerId", request.getSellerId());

        // 3. [이유] 글이 언제 올라왔는지 기록합니다.
        // 사용자의 휴대폰 시간이 아닌, 구글 서버의 정확한 시간을 기록하기 위해 serverTimestamp를 사용합니다.
        data.put("createdAt", FieldValue.serverTimestamp());

        // 4. [이유] 완성된 data 맵을 실제로 DB(Firestore)에 씁니다.
        // .get()을 붙여서 데이터 저장이 확실히 끝날 때까지 기다린 후 다음 줄로 넘어갑니다.
        posts.set(data).get();

        // 5. 생성된 문서의 고유 ID를 리턴합니다.
        return posts.getId();
    }
}