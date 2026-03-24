package com.example.dukdang.dto;

import com.example.dukdang.entity.Category;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
public class AuctionPostRequestDto {
    private String title;
    private String description;
    private int minPrice;           // 최소 입찰 시작가
    private Category category;
    private String imageUrl;
    private LocalDateTime startTime; // 경매 시작 시각
    private int durationHours;       // 경매 진행 시간 (12, 24, 48, 72 등)
}