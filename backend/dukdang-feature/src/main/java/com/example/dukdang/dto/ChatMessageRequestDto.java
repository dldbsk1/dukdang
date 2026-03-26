package com.example.dukdang.dto;

import lombok.Getter;

// WebSocket으로 클라이언트가 보내는 메시지
@Getter
public class ChatMessageRequestDto {
    private Long roomId;     // 어느 채팅방에 보낼지
    private String content;  // 메시지 내용
}