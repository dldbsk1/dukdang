package com.example.dukdang.entity;

public enum AuctionStatus {
    WAITING,    // 등록됨 (시작 전)
    ACTIVE,     // 경매 진행중
    ENDED,      // 종료됨 (낙찰자 결정 대기)
    COMPLETED,  // 거래 완료
    CANCELLED   // 유찰 (입찰자 없음)
}