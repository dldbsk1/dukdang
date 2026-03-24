package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

// 채팅방 = 게시글 하나에 대해 구매자가 판매자에게 말을 거는 공간
// 같은 게시글이라도 구매자가 다르면 채팅방이 별도로 생성됨
// (게시글 + 구매자) 조합이 고유해야 함 → uniqueConstraints로 중복 방지
@Entity
@Table(
        name = "chat_rooms",
        uniqueConstraints = @UniqueConstraint(columnNames = {"trade_post_id", "buyer_id"})
)
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ChatRoom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 어떤 게시글에 대한 채팅방인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trade_post_id", nullable = false)
    private TradePost tradePost;

    // 판매자 — tradePost.getSeller()로도 접근 가능하지만
    // 채팅방 조회 시 매번 tradePost까지 조인하지 않으려고 직접 연결해둠
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    // 구매자 (채팅을 먼저 건 사람)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id", nullable = false)
    private User buyer;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;

    public static ChatRoom create(TradePost tradePost, User buyer) {
        ChatRoom room = new ChatRoom();
        room.tradePost = tradePost;
        room.seller = tradePost.getSeller();
        room.buyer = buyer;
        return room;
    }

    // 이 채팅방의 참여자인지 확인
    // — 판매자도 구매자도 아닌 제3자는 채팅방 접근 불가
    public boolean isParticipant(User user) {
        return seller.getId().equals(user.getId()) ||
                buyer.getId().equals(user.getId());
    }
}