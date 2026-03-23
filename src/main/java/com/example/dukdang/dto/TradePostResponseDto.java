package com.example.dukdang.dto;

import com.example.dukdang.entity.TradePost;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

// 단건 조회 응답 (전체 정보)
@Getter
@AllArgsConstructor
public class TradePostResponseDto {
    private Long id;
    private String title;
    private String description;
    private int price;
    private String category;
    private String status;
    private String imageUrl;
    private String sellerNickname;
    private Long sellerId;
    private int viewCount;
    private long wishCount;
    private boolean isWished;        // 내가 찜했는지 여부
    private LocalDateTime postTime;

    public static TradePostResponseDto from(TradePost post, long wishCount, boolean isWished) {
        return new TradePostResponseDto(
                post.getId(),
                post.getTitle(),
                post.getDescription(),
                post.getPrice(),
                post.getCategory().name(),
                post.getStatus().name(),
                post.getImageUrl(),
                post.getSeller().getNickname(),
                post.getSeller().getId(),
                post.getViewCount(),
                wishCount,
                isWished,
                post.getPostTime()
        );
    }
}