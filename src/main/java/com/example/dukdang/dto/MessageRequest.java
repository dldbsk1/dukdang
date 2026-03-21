package com.example.dukdang.dto;

import lombok.Data;

@Data
public class MessageRequest {
    private String roomId;    // 어느 방인지
    private String senderId;  // 누가 보냈는지
    private String content;   // 내용
}
