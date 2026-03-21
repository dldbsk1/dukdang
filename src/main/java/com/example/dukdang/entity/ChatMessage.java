// entity/ChatMessage.java
package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ChatMessage {
    //실제로 주고 받는 메세지
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id")
    //어느 방 소속인지
    private ChatRoom chatRoom;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_id")
    //누가 보냈는지
    private User sender;

    @Column(nullable = false, columnDefinition = "TEXT")
    //내용이 뭔지
    private String content;

    @CreatedDate
    @Column(updatable = false)
    //언제 보냈는지
    private LocalDateTime sentAt;

    public static ChatMessage create(ChatRoom chatRoom, User sender, String content) {
        ChatMessage message = new ChatMessage();
        message.chatRoom = chatRoom;
        message.sender = sender;
        message.content = content;
        return message;
    }
}