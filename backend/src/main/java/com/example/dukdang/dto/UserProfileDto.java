package com.example.dukdang.dto;

import com.example.dukdang.entity.User;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

public class UserProfileDto {

    // ── 서버 -> iOS (조회용 응답 DTO) ──
    @Getter
    @AllArgsConstructor
    public static class Response {
        private String name;
        private String profileImageName;
        private String location;
        private Double temperature;
        private int tradeCount;

        public static Response from(User user, int tradeCount) {
            return new Response(
                    user.getNickname(),
                    user.getProfileImg() != null ? user.getProfileImg() : "profile", // 기본 이미지
                    user.getLocation(),
                    user.getTemperature(),
                    tradeCount
            );
        }
    }

    // ── iOS -> 서버 (수정용 요청 DTO) ──
    @Getter
    @Setter
    @NoArgsConstructor
    public static class UpdateRequest {
        private String name;
        private String location;
        private String profileImageName;
    }
}
