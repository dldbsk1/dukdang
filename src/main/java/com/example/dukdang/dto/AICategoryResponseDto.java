package com.example.dukdang.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class AICategoryResponseDto {
    private String category;
    private String reason;      // 분류 이유 — 프론트에서 툴팁으로 보여줄 수 있음
    private double confidence;  // 확신도 0.0 ~ 1.0
}