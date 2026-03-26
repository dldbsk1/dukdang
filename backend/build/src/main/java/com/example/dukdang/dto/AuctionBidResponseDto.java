package com.example.dukdang.dto;

import com.example.dukdang.entity.AuctionBid;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class AuctionBidResponseDto {
    private Long id;
    private Long auctionPostId;
    private int bidPrice;
    private boolean isHighestBid;   // 내 입찰이 현재 최고가인지
    private LocalDateTime postTime;

    public static AuctionBidResponseDto from(AuctionBid bid, boolean isHighestBid) {
        return new AuctionBidResponseDto(
                bid.getId(),
                bid.getAuctionPost().getId(),
                bid.getBidPrice(),
                isHighestBid,
                bid.getPostTime()
        );
    }
}