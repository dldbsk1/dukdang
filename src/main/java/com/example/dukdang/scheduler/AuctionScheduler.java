package com.example.dukdang.scheduler;

import com.example.dukdang.service.AuctionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class AuctionScheduler {

    private final AuctionService auctionService;

    // 1분마다 실행 — WAITING → ACTIVE 전환
    // cron = "초 분 시 일 월 요일"
    @Scheduled(cron = "0 * * * * *")
    public void activateAuctions() {
        log.info("[스케줄러] WAITING → ACTIVE 전환 체크");
        auctionService.activateScheduled();
    }

    // 1분마다 실행 — ACTIVE → ENDED 전환 + 낙찰자 결정
    @Scheduled(cron = "30 * * * * *")  // 매 분 30초에 실행 (위와 겹치지 않게)
    public void endAuctions() {
        log.info("[스케줄러] ACTIVE → ENDED 전환 체크");
        auctionService.endScheduled();
    }
}