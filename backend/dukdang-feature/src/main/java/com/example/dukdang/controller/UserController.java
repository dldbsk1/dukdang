package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.UserProfileDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.repository.PostSearchRepository;
import com.example.dukdang.repository.UserRepository;
import com.example.dukdang.service.ImageService; // 💡 [추가] 이미지 변환 마법사 임포트!
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserRepository userRepository;
    private final PostSearchRepository postSearchRepository;
    private final ImageService imageService; // 💡 [추가] 이미지 서비스 의존성 주입!

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

        String finalImageUrl = request.getProfileImageName();

        // 💡 [핵심 추가] 프론트에서 Base64 사진(data:image...)을 보냈다면, ImageService를 통해 진짜 URL로 변환합니다!
        if (finalImageUrl != null && finalImageUrl.startsWith("data:image")) {
            // ImageService가 List를 받으므로 List로 감싸서 보내고 첫 번째 결과만 가져옵니다.
            List<String> savedUrls = imageService.saveImages(List.of(finalImageUrl));
            if (!savedUrls.isEmpty()) {
                finalImageUrl = savedUrls.get(0);
            }
        }

        // 💡 유저 정보 업데이트 (변환된 깔끔한 URL 저장)
        user.updateProfile(request.getName(), request.getLocation(), finalImageUrl);

        int tradeCount = postSearchRepository.findBySellerOrderByPostTimeDesc(user).size();
        return ResponseEntity.ok(ApiResponse.ok(UserProfileDto.Response.from(user, tradeCount)));
    }
}