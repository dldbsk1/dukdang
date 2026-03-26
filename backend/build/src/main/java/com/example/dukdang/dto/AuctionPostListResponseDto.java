package com.example.dukdang.dto;

import com.example.dukdang.entity.AuctionPost;
import lombok.AllArgsConstructor;
import lombok.Getter;
import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class AuctionPostListResponseDto {
    private Long id;
    private String title;
    private int minPrice;
    private Integer currentHighestPrice;
    private String category;
    private String status;
    private String imageUrl; // 💡 목록은 1장이므로 String 유지
    private String sellerNickname;
    private long bidCount;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private LocalDateTime postTime;

    public static AuctionPostListResponseDto from(AuctionPost post, long bidCount) {
        // 💡 사진 보따리에서 첫 번째 1장만 뽑아냅니다!
        String firstImage = (post.getImageUrls() != null && !post.getImageUrls().isEmpty())
                ? post.getImageUrls().get(0) : "";

        return new AuctionPostListResponseDto(
                post.getId(), post.getTitle(), post.getMinPrice(), post.getCurrentHighestPrice(),
                post.getCategory().name(), post.getStatus().name(), firstImage,
                post.getSeller().getNickname(), bidCount, post.getStartTime(),
                post.getEndTime(), post.getPostTime()
        );
    }
}