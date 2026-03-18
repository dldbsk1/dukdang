package com.example.dukdang.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor

public class TradePostResponseDto {
    private Long id;
    private String title;
    private int price;
    private String category;
    private String status;
    private String imageUrl;
    private String sellerName;
    private int viewCount;
    private LocalDateTime postTime;

}
