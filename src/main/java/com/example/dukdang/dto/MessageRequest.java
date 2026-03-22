package com.example.dukdang.dto;

import lombok.Data;
//DTO 역할:클라이언트(앱/웹)와 서버 간에 데이터를 주고받을 때 사용하는 '데이터 운반용 상자'
@Data
public class MessageRequest {
    private String roomId;    // 어느 방인지
    private String senderId;  // 누가 보냈는지
    private String content;   // 내용
}
