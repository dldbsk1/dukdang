package com.example.dukdang.controller;

import com.example.dukdang.dto.PostRequest;
import com.example.dukdang.service.PostService;
import com.google.cloud.firestore.Firestore;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/trade")
public class TradeController {
    private final PostService postService;
    private final Firestore db;

    /**
     * [함수 목적] 사용자가 작성한 판매글을 시스템에 등록합니다.
     * [이유] 컨트롤러는 입구 역할만 하고, 실제 데이터 가공과 저장은 PostService라는
     * 전문 해결사에게 맡기는 구조(계층화)를 지키기 위해 작성되었습니다.
     */
    @PostMapping("/post")
    public String createPost(@RequestBody PostRequest request) throws Exception {
        return postService.registerPost(request);
    }

    /**
     * [함수 목적] 게시글 하트(찜)를 누르면 추가하고, 다시 누르면 취소합니다.
     * [핵심 포인트]
     * 1. docId를 '사용자ID_게시글ID' 조합으로 만들어 중복 찜을 원천 차단합니다.
     * 2. 게시글 문서 안의 'likeCount'를 실시간으로 더하거나 빼서,
     * 나중에 목록을 볼 때 매번 수만 개의 찜 데이터를 세지 않아도 되게 최적화했습니다.
     */
    @PostMapping("/wish")
    public Map<String, Object> toggleWish(@RequestParam String userId, @RequestParam String postId) throws Exception {
        String docId = userId + "_" + postId; // 예: "user123_post456"
        var wishRef = db.collection("wishlist").document(docId);
        var postRef = db.collection("posts").document(postId);

        boolean isAdded;
        if (wishRef.get().get().exists()) {
            // 이미 있으면? -> 취소하고 싶은 거니까 삭제!
            wishRef.delete();
            // 좋아요 수 -1 (increment(-1)은 원자적 연산이라 데이터가 꼬이지 않아요)
            postRef.update("likeCount", com.google.cloud.firestore.FieldValue.increment(-1));
            isAdded = false;
        } else {
            // 없으면? -> 새로 찜 등록!
            wishRef.set(Map.of("userId", userId, "postId", postId));
            postRef.update("likeCount", com.google.cloud.firestore.FieldValue.increment(1));
            isAdded = true;
        }

        // 화면에 즉시 바뀐 좋아요 숫자를 보여주기 위해 최신 값을 리턴합니다.
        int currentLikes = postRef.get().get().getLong("likeCount").intValue();
        return Map.of("status", isAdded ? "added" : "removed", "likeCount", currentLikes);
    }

    /**
     * [함수 목적] 게시글 하나를 클릭했을 때 모든 내용을 보여줍니다.
     * [이유] 단순한 글 내용뿐만 아니라, "지금 이 글을 보고 있는 주영 님이
     * 이 글을 이미 찜했는지(isLiked)" 여부를 알려줘야 화면에 빨간 하트를 채울 수 있습니다.
     */
    @GetMapping("/post/{postId}")
    public Map<String, Object> getPostDetail(@PathVariable String postId, @RequestParam String userId) throws Exception {
        var postDoc = db.collection("posts").document(postId).get().get();
        if (postDoc.exists()) {
            Map<String, Object> data = postDoc.getData();
            String wishId = userId + "_" + postId;
            // 사용자의 찜 목록에 해당 글이 있는지 즉석에서 확인합니다.
            boolean isLiked = db.collection("wishlist").document(wishId).get().get().exists();
            data.put("isLiked", isLiked);
            return data;
        }
        return null;
    }

    /**
     * [함수 목적] 마이페이지 등에서 '내가 찜한 글' 목록만 모아서 보여줍니다.
     * [이유] 찜 목록에서 ID들을 먼저 찾고, 그 ID를 이용해 게시글 상세 데이터를
     * 하나씩 가져와서 리스트로 만들어줍니다.
     */
    @GetMapping("/wish/list")
    public List<Map<String, Object>> getMyWishlist(@RequestParam String userId) throws Exception {
        var wishQuery = db.collection("wishlist").whereEqualTo("userId", userId).get().get();
        List<Map<String, Object>> wishPosts = new ArrayList<>();

        for (var doc : wishQuery.getDocuments()) {
            String postId = doc.getString("postId");
            var postDoc = db.collection("posts").document(postId).get().get();
            // 글이 삭제되었을 수도 있으니 존재하는 경우에만 리스트에 담습니다.
            if (postDoc.exists()) wishPosts.add(postDoc.getData());
        }
        return wishPosts;
    }
}
