package com.example.dukdang.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class LoginResponseDto {
    private String token;
    private Long userId; // 💡 iOS가 말풍선 위치를 잡을 때 꼭 필요한 값!
}
