package com.example.dukdang.dto;

import com.example.dukdang.entity.ChatMessage;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

// 메시지 응답 — WebSocket으로 채팅방 구독자에게 뿌려지는 형태
@Getter
@AllArgsConstructor
public class ChatMessageResponseDto {
    private Long id;
    private Long roomId;
    private Long senderId;
    private String senderNickname;
    private String content;
    private boolean isRead;
    private LocalDateTime postTime;

    public static ChatMessageResponseDto from(ChatMessage message) {
        return new ChatMessageResponseDto(
                message.getId(),
                message.getChatRoom().getId(),
                message.getSender().getId(),
                message.getSender().getNickname(),
                message.getContent(),
                message.isRead(),
                message.getPostTime()
        );
    }
}