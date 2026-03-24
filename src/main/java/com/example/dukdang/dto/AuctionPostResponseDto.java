package com.example.dukdang.dto;

import com.example.dukdang.entity.AuctionPost;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class AuctionPostResponseDto {
    private Long id;
    private String title;
    private String description;
    private int minPrice;
    private Integer currentHighestPrice; // 판매자 조회 시 null 처리
    private String category;
    private String status;
    private String imageUrl;
    private String sellerNickname;
    private Long sellerId;
    private long bidCount;
    private String winnerNickname;       // 경매 종료 후에만 노출
    private boolean isMyHighestBid;      // 내가 현재 최고 입찰자인지
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private LocalDateTime postTime;

    // isSeller = true면 진행중 입찰가 숨김
    public static AuctionPostResponseDto from(AuctionPost post,
                                              long bidCount,
                                              boolean isSeller,
                                              boolean isMyHighestBid) {
        boolean isEnded = post.getStatus() == com.example.dukdang.entity.AuctionStatus.ENDED
                || post.getStatus() == com.example.dukdang.entity.AuctionStatus.COMPLETED;

        // 판매자이고 경매 진행중이면 입찰가 숨김
        Integer visiblePrice = (isSeller && !isEnded)
                ? null
                : post.getCurrentHighestPrice();

        // 낙찰자 닉네임은 종료 후에만
        String winnerNickname = isEnded && post.getWinner() != null
                ? post.getWinner().getNickname()
                : null;

        return new AuctionPostResponseDto(
                post.getId(),
                post.getTitle(),
                post.getDescription(),
                post.getMinPrice(),
                visiblePrice,
                post.getCategory().name(),
                post.getStatus().name(),
                post.getImageUrl(),
                post.getSeller().getNickname(),
                post.getSeller().getId(),
                bidCount,
                winnerNickname,
                isMyHighestBid,
                post.getStartTime(),
                post.getEndTime(),
                post.getPostTime()
        );
    }
}