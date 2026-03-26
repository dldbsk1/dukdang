package com.example.dukdang.dto;

import lombok.Getter;

@Getter
public class AuctionBidRequestDto {
    private Long auctionPostId;
    private int bidPrice;   // 입찰 금액
}