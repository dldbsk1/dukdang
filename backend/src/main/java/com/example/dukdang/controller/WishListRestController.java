package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.WishListResponseDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.entity.WishList;
import com.example.dukdang.repository.PostSearchRepository;
import com.example.dukdang.repository.UserRepository;
import com.example.dukdang.repository.WishListRepository;
import com.example.dukdang.service.WishListService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/wishlist")
@RequiredArgsConstructor
public class WishListRestController {
    private final WishListService wishListService;
    private final UserRepository userRepository;

    private final WishListRepository wishListRepository;
    private final PostSearchRepository postSearchRepository;

    // WishListRestController.java 의 toggle 메서드
    @PostMapping("/{postId}")
    public ResponseEntity<ApiResponse<Boolean>> toggle(
            @PathVariable Long postId,
            @AuthenticationPrincipal Object principal // 💡 Principal 대신 인증된 객체를 직접 받음
    ) {
        String email;

        // principal이 User 엔티티라면 바로 이메일 추출, 아니면 getName() 사용
        if (principal instanceof com.example.dukdang.entity.User) {
            email = ((com.example.dukdang.entity.User) principal).getEmail();
        } else if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
            email = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
        } else {
            email = principal.toString();
        }

        System.out.println("👉 [진짜 이메일 확인]: " + email);

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        boolean result = wishListService.toggleWishList(postId, user);
        return ResponseEntity.ok(ApiResponse.ok(result));
    }

    @GetMapping("/check/{postId}")
    public ResponseEntity<ApiResponse<Boolean>> checkStatus(@PathVariable Long postId, Principal principal) {
        if (principal == null) return ResponseEntity.ok(ApiResponse.ok(false));

        User user = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // 💡 레포지토리의 exists 기능을 활용해 찜 여부 확인
        boolean isLiked = wishListRepository.existsByUserAndTradePost(
                user,
                postSearchRepository.findById(postId).orElseThrow()
        );
        // 💡 WishListRepository의 existsByUserAndTradePost를 사용
        //boolean isLiked = wishListService.isLiked(postId, user);
        return ResponseEntity.ok(ApiResponse.ok(isLiked));
    }
    // ── 내 찜 목록 전체 조회 (iOS WishlistView용) ──
    @GetMapping
    public ResponseEntity<ApiResponse<List<WishListResponseDto>>> getMyList(
            @AuthenticationPrincipal Object principal
    ) {
        String email;

        // 1. JWT 토큰에서 유저 이메일 추출 (toggle 메서드와 동일한 안전한 방식)
        if (principal instanceof com.example.dukdang.entity.User) {
            email = ((com.example.dukdang.entity.User) principal).getEmail();
        } else if (principal instanceof org.springframework.security.core.userdetails.UserDetails) {
            email = ((org.springframework.security.core.userdetails.UserDetails) principal).getUsername();
        } else {
            email = principal.toString();
        }

        // 2. 이메일로 진짜 유저 찾기
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // 3. 서비스에서 찜 목록 엔티티를 가져옴
        // 4. 무한 루프(순환 참조)를 막기 위해 DTO로 변환!
        List<WishListResponseDto> responses = wishListService.getMyWishList(user).stream()
                .map(WishListResponseDto::from)
                .toList();

        // 5. iOS가 기다리는 JSON 형태로 포장해서 반환
        return ResponseEntity.ok(ApiResponse.ok(responses));
    }
}
