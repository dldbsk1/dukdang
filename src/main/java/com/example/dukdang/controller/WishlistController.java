package com.example.dukdang.controller;

import com.example.dukdang.service.WishlistService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.*;

/**
 * [클래스 목적] 특정 사용자가 찜한(Wishlist) 게시글 목록을 조회하는 API 요청만을 전담하여 처리하는 독립적인 컨트롤러입니다.
 */
@RestController // 메서드의 반환값을 뷰(HTML)가 아닌 데이터(JSON, 문자열 등)로 클라이언트의 응답 본문(Response Body)에 직접 반환합니다.
@RequiredArgsConstructor // final로 선언된 필드(wishlistService)에 대한 생성자를 자동 생성하여, 스프링 컨테이너로부터 의존성을 주입받습니다.
@RequestMapping("/api/trade") // 이 컨트롤러 내 모든 API 엔드포인트가 공유하는 기본 URL 경로를 지정합니다.
public class WishlistController {

    // DB(Firestore) 접근 및 위시리스트 데이터 가공 로직을 수행할 서비스 계층 객체입니다.
    private final WishlistService wishlistService;

    /**
     * [메서드 목적] 클라이언트로부터 특정 사용자의 아이디를 전달받아, 해당 사용자가 찜한 게시글 전체 목록을 조회하여 반환합니다.
     */
    @GetMapping("/wish/list") // HTTP GET 메서드 요청을 "/api/trade/wish/list" 경로에 매핑하여 리소스 조회를 처리합니다.
    public List<Map<String, Object>> getMyWishlist(
            // @RequestParam: HTTP 요청의 쿼리 파라미터(query string)에서 'userId' 값을 추출하여 바인딩합니다. (예: ?userId=user123)
            @RequestParam String userId) throws Exception {

        // 서비스 계층의 로직을 호출하여 찜한 게시글 목록 데이터를 List<Map> 형태로 가져오고, 이를 클라이언트에게 JSON 배열 형태로 최종 응답합니다.
        return wishlistService.getMyWishlist(userId);
    }
}