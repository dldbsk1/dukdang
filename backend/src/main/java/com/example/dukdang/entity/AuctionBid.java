package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "auction_bids")
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class AuctionBid {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "auction_post_id", nullable = false)
    private AuctionPost auctionPost;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "bidder_id", nullable = false)
    private User bidder;

    @Column(nullable = false)
    private int bidPrice;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;

    public static AuctionBid create(AuctionPost post, User bidder, int bidPrice) {
        AuctionBid bid = new AuctionBid();
        bid.auctionPost = post;
        bid.bidder = bidder;
        bid.bidPrice = bidPrice;
        return bid;
    }
}