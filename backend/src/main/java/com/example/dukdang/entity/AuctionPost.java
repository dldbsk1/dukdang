package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "auction_posts")
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class AuctionPost {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    // 판매자가 설정한 최소 입찰 시작가
    @Column(nullable = false)
    private int minPrice;

    // 현재 최고 입찰가 — 입찰이 들어올 때마다 갱신
    // null = 아직 입찰 없음
    private Integer currentHighestPrice;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AuctionStatus status;

    // 💡 [핵심] 여러 장의 경매 사진 URL을 저장할 리스트
    @ElementCollection
    @CollectionTable(name = "auction_post_images", joinColumns = @JoinColumn(name = "auction_id"))
    @Column(name = "image_url")
    private List<String> imageUrls = new ArrayList<>();

    // 경매 시작/종료 시각 — 등록 시점에 결정
    @Column(nullable = false)
    private LocalDateTime startTime;

    @Column(nullable = false)
    private LocalDateTime endTime;

    // 낙찰자 — 경매 종료 후 최고 입찰자
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "winner_id")
    private User winner;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;

    // 💡 [수정 완료] 필드 이름에 완벽하게 맞춘 create 메서드
    public static AuctionPost create(User seller, String title, String description,
                                     int minPrice, Category category, List<String> imageUrls,
                                     LocalDateTime startTime, LocalDateTime endTime) {
        AuctionPost post = new AuctionPost();
        post.seller = seller;
        post.title = title;
        post.description = description;
        post.minPrice = minPrice;
        post.currentHighestPrice = null;
        post.category = category;
        post.imageUrls = imageUrls; // 💡 사진 보따리 저장
        post.startTime = startTime;
        post.endTime = endTime;

        // 등록 즉시 시작 시각이 지났으면 바로 ACTIVE, 아니면 WAITING
        post.status = LocalDateTime.now().isAfter(startTime)
                ? AuctionStatus.ACTIVE
                : AuctionStatus.WAITING;

        return post;
    }

    // 입찰가 갱신 — 새 입찰이 들어올 때 호출
    public void updateHighestPrice(int price) {
        this.currentHighestPrice = price;
    }

    // 스케줄러가 호출 — WAITING → ACTIVE
    public void activate() {
        this.status = AuctionStatus.ACTIVE;
    }

    // 스케줄러가 호출 — ACTIVE → ENDED + 낙찰자 결정
    public void end(User winner) {
        this.status = winner != null ? AuctionStatus.ENDED : AuctionStatus.CANCELLED;
        this.winner = winner;
    }

    // 거래 완료 처리
    public void complete() {
        this.status = AuctionStatus.COMPLETED;
    }
}