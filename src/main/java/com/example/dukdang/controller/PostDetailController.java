package com.example.dukdang.controller;

import com.example.dukdang.service.PostDetailService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.*;

/**
 * [클래스 목적] 특정 단일 게시글과 관련된 상세 데이터 조회, 찜 상태 토글, 판매 상태 업데이트 API 요청을 전담하여 처리하는 컨트롤러입니다.
 */
@RestController // 반환되는 데이터를 뷰(HTML)가 아닌 JSON 등의 데이터 형식으로 클라이언트의 응답 본문(Response Body)에 직접 작성합니다.
@RequiredArgsConstructor // final로 선언된 필드(postDetailService)에 대해 생성자를 자동 생성하여 의존성을 주입받습니다.
@RequestMapping("/api/trade") // 이 컨트롤러 내 모든 API 엔드포인트의 기본 경로(Base URL)를 지정합니다.
public class PostDetailController {

    // 비즈니스 로직 및 DB 연동을 처리할 서비스 계층 객체입니다.
    private final PostDetailService postDetailService;

    /**
     * [메서드 목적] 클라이언트의 특정 게시글 상세 정보 조회 요청을 처리합니다.
     */
    @GetMapping("/post/{postId}") // HTTP GET 메서드 요청을 매핑하여 리소스를 조회합니다.
    public Map<String, Object> getPostDetail(
            // @PathVariable: URL 경로에 포함된 변수({postId}) 값을 추출하여 파라미터로 바인딩합니다.
            @PathVariable String postId,
            // @RequestParam: HTTP 요청 파라미터(query string)에서 값을 추출합니다. 해당 게시글에 대한 요청 사용자의 찜 여부를 판별하기 위해 사용됩니다.
            @RequestParam String userId) throws Exception {

        return postDetailService.getPostDetail(postId, userId);
    }

    /**
     * [메서드 목적] 특정 게시글에 대한 사용자의 찜(Wishlist) 상태를 추가 또는 취소(토글)하는 요청을 처리합니다.
     */
    @PostMapping("/wish") // HTTP POST 메서드 요청을 매핑하여 서버의 상태(찜 데이터)를 변경하거나 생성합니다.
    public Map<String, Object> toggleWish(
            @RequestParam String userId,
            @RequestParam String postId) throws Exception {

        // 서비스 계층에서 찜 상태 토글 로직을 수행하고 결과(추가됨: true, 취소됨: false)를 반환받습니다.
        boolean isAdded = postDetailService.toggleWish(userId, postId);

        // Map.of를 사용하여 처리 결과를 클라이언트가 식별하기 쉬운 상태 값("added" 또는 "removed")으로 가공하여 JSON 형태로 응답합니다.
        return Map.of("status", isAdded ? "added" : "removed");
    }

    /**
     * [메서드 목적] 판매자가 자신의 게시글 판매 상태(예: 판매중, 예약중, 거래완료)를 변경하는 요청을 처리합니다.
     */
    @PatchMapping("/post/{postId}/status") // HTTP PATCH 메서드 요청을 매핑합니다. 리소스의 전체가 아닌 '일부(status)'만 수정할 때 RESTful 표준에 맞춰 사용합니다.
    public String updateStatus(
            @PathVariable String postId,
            @RequestParam String status) throws Exception {

        // 전달받은 새로운 상태 값으로 DB 리소스를 업데이트합니다.
        postDetailService.updateStatus(postId, status);
        return "success";
    }
}