package com.example.dukdang.dto;

import com.example.dukdang.entity.TradePost;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

// dto/TradePostListResponseDto.java  — 목록 조회 응답 (요약 정보만)
@Getter
@AllArgsConstructor
public class TradePostListResponseDto {
    private Long id;
    private String title;
    private int price;
    private String category;
    private String status;
    private String imageUrl;
    private String sellerNickname;
    private int viewCount;
    private long wishCount;
    private LocalDateTime postTime;

    public static TradePostListResponseDto from(TradePost post, long wishCount) {
        return new TradePostListResponseDto(
                post.getId(),
                post.getTitle(),
                post.getPrice(),
                post.getCategory().name(),
                post.getStatus().name(),
                post.getImageUrl(),
                post.getSeller().getNickname(),
                post.getViewCount(),
                wishCount,
                post.getPostTime()
        );
    }
}