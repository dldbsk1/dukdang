// dto/ChatMessageResponseDto.java
package com.example.dukdang.dto;

import com.example.dukdang.entity.ChatMessage;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ChatMessageResponseDto {
    private Long messageId;
    private Long senderId;
    private String senderNickname;
    private String content;
    private LocalDateTime sentAt;

    public static ChatMessageResponseDto from(ChatMessage message) {
        return new ChatMessageResponseDto(
                message.getId(),
                message.getSender().getId(),
                message.getSender().getNickname(),
                message.getContent(),
                message.getSentAt()
        );
    }
}