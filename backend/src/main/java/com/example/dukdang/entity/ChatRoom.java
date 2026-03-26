package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

// 💡 [핵심 수정] uniqueConstraints 제약 조건을 지웠습니다! (일반/경매 공용으로 쓰기 위함)
@Entity
@Table(name = "chat_rooms")
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ChatRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 💡 일반 거래 게시글 (경매방일 때는 null이 됨, nullable = false 속성 지움!)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trade_post_id")
    private TradePost tradePost;

    // 💡 [추가] 경매 거래 게시글 (일반 거래방일 때는 null이 됨)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "auction_post_id")
    private AuctionPost auctionPost;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id", nullable = false)
    private User buyer;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;

    // 1. 기존 일반 거래용 채팅방 생성
    public static ChatRoom create(TradePost tradePost, User buyer) {
        ChatRoom room = new ChatRoom();
        room.tradePost = tradePost;
        room.seller = tradePost.getSeller();
        room.buyer = buyer;
        return room;
    }

    // 💡 2. 새로운 경매 낙찰용 채팅방 생성!
    public static ChatRoom createForAuction(AuctionPost auctionPost, User winner) {
        ChatRoom room = new ChatRoom();
        room.auctionPost = auctionPost;
        room.seller = auctionPost.getSeller();
        room.buyer = winner;
        return room;
    }

    public boolean isParticipant(User user) {
        return seller.getId().equals(user.getId()) || buyer.getId().equals(user.getId());
    }

    // 💡 [마법의 코드] 경매방이든 일반방이든 알아서 제목, ID, 사진을 꺼내주는 헬퍼 메서드들!
    public Long getPostId() {
        return tradePost != null ? tradePost.getId() : auctionPost.getId();
    }

    public String getPostTitle() {
        return tradePost != null ? tradePost.getTitle() : auctionPost.getTitle();
    }

    public String getPostImageUrl() {
        if (tradePost != null && tradePost.getImageUrls() != null && !tradePost.getImageUrls().isEmpty()) {
            return tradePost.getImageUrls().get(0);
        }
        if (auctionPost != null && auctionPost.getImageUrls() != null && !auctionPost.getImageUrls().isEmpty()) {
            return auctionPost.getImageUrls().get(0);
        }
        return "";
    }
}