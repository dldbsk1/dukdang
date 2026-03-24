package com.example.dukdang.repository;

import com.example.dukdang.entity.AuctionPost;
import com.example.dukdang.entity.AuctionStatus;
import com.example.dukdang.entity.Category;
import com.example.dukdang.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface AuctionPostRepository extends JpaRepository<AuctionPost, Long> {

    // 목록 조회 — 카테고리/키워드 필터 + 페이징
    @Query("SELECT a FROM AuctionPost a WHERE " +
            "(:category IS NULL OR a.category = :category) AND " +
            "(:keyword IS NULL OR a.title LIKE %:keyword%) " +
            "ORDER BY a.postTime DESC")
    Page<AuctionPost> search(@Param("category") Category category,
                             @Param("keyword") String keyword,
                             Pageable pageable);

    // 내가 등록한 경매 목록
    List<AuctionPost> findBySellerOrderByPostTimeDesc(User seller);

    // 스케줄러용 — WAITING 중 시작 시각 지난 것 (ACTIVE로 전환 대상)
    List<AuctionPost> findByStatusAndStartTimeBefore(
            AuctionStatus status, LocalDateTime now);

    // 스케줄러용 — ACTIVE 중 종료 시각 지난 것 (ENDED로 전환 대상)
    List<AuctionPost> findByStatusAndEndTimeBefore(
            AuctionStatus status, LocalDateTime now);
}