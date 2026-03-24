package com.example.dukdang.dto;

import com.example.dukdang.entity.AuctionPost;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

// 목록에서는 입찰가를 보여줌 (구매자도 목록에서는 볼 수 있음)
@Getter
@AllArgsConstructor
public class AuctionPostListResponseDto {
    private Long id;
    private String title;
    private int minPrice;
    private Integer currentHighestPrice;  // null = 입찰 없음
    private String category;
    private String status;
    private String imageUrl;
    private String sellerNickname;
    private long bidCount;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private LocalDateTime postTime;

    public static AuctionPostListResponseDto from(AuctionPost post, long bidCount) {
        return new AuctionPostListResponseDto(
                post.getId(),
                post.getTitle(),
                post.getMinPrice(),
                post.getCurrentHighestPrice(),
                post.getCategory().name(),
                post.getStatus().name(),
                post.getImageUrl(),
                post.getSeller().getNickname(),
                bidCount,
                post.getStartTime(),
                post.getEndTime(),
                post.getPostTime()
        );
    }
}