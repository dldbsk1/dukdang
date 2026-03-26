package com.example.dukdang.scheduler;

import com.example.dukdang.service.AuctionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

@Slf4j
@Configuration
@EnableScheduling // 💡 [핵심 원인] 이 스위치가 없어서 서버가 꿀잠을 자고 있었습니다!
@RequiredArgsConstructor
public class AuctionScheduler {

    private final AuctionService auctionService;

    // 1분마다 실행 — WAITING → ACTIVE 전환
    @Scheduled(cron = "0 * * * * *")
    public void activateAuctions() {
        log.info("[스케줄러] WAITING → ACTIVE 전환 체크");
        auctionService.activateScheduled();
    }

    // 1분마다 실행 — ACTIVE → ENDED 전환 + 낙찰자 결정
    @Scheduled(cron = "30 * * * * *")
    public void endAuctions() {
        log.info("[스케줄러] ACTIVE → ENDED 전환 체크");
        auctionService.endScheduled();
    }
}