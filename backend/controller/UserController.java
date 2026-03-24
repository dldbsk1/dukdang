package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.UserProfileDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.repository.PostSearchRepository;
import com.example.dukdang.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;
    private final PostSearchRepository postSearchRepository;

    // ── 내 프로필 조회 API ──
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileDto.Response>> getMyProfile(Principal principal) {
        User user = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // 내가 올린 게시글 개수를 거래 횟수로 임시 사용
        int tradeCount = postSearchRepository.findBySellerOrderByPostTimeDesc(user).size();

        return ResponseEntity.ok(ApiResponse.ok(UserProfileDto.Response.from(user, tradeCount)));
    }

    // ── 내 프로필 수정 API ──
    @PutMapping("/me")
    @Transactional // 변경 감지로 자동 DB 저장
    public ResponseEntity<ApiResponse<UserProfileDto.Response>> updateMyProfile(
            @RequestBody UserProfileDto.UpdateRequest request,
            Principal principal) {

        User user = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // 유저 정보 업데이트
        user.updateProfile(request.getName(), request.getLocation(), request.getProfileImageName());

        int tradeCount = postSearchRepository.findBySellerOrderByPostTimeDesc(user).size();
        return ResponseEntity.ok(ApiResponse.ok(UserProfileDto.Response.from(user, tradeCount)));
    }
}
