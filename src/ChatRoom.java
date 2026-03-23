// entity/ChatRoom.java
package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ChatRoom {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id")
    private User buyer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id")
    private User seller;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id")
    private TradePost tradePost; // 어떤 물건에 대한 채팅인지 연결

    private String lastMessage;

    @LastModifiedDate
    private LocalDateTime lastTimestamp; // 마지막 대화 시간 (목록 정렬용)

    public static ChatRoom create(User buyer, User seller, TradePost tradePost) {
        ChatRoom room = new ChatRoom();
        //누가 사는지
        room.buyer = buyer;
        //누가 파는지
        room.seller = seller;
        //어떤 제품에 대한 대화인지
        room.tradePost = tradePost;
        return room;
    }

    // 새로운 메시지가 올 때마다 채팅방 정보 업데이트
    public void updateLastMessage(String message) {
        this.lastMessage = message;
    }
}