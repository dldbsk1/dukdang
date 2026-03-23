package com.example.dukdang.controller;

import com.example.dukdang.dto.ChatMessageRequestDto;
import com.example.dukdang.dto.ChatMessageResponseDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.exception.CustomException;
import com.example.dukdang.exception.ErrorCode;
import com.example.dukdang.repository.UserRepository;
import com.example.dukdang.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;

import java.security.Principal;

// WebSocket 메시지 처리 담당
// @RestController가 아닌 @Controller — WebSocket은 HTTP 응답 반환이 아님
@Controller
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;
    // SimpMessagingTemplate: 특정 경로를 구독 중인 클라이언트에게 메시지를 밀어주는 도구
    private final UserRepository userRepository;

    // 클라이언트가 /pub/chat/message 로 메시지 전송 시 이 메서드 실행
    @MessageMapping("/chat/message")
    public void sendMessage(ChatMessageRequestDto dto,
                            Principal principal) {

        if (principal == null) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }

        // Principal에서 이메일 꺼내서 직접 유저 조회
        User sender = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // 1. DB에 메시지 저장
        ChatMessageResponseDto response = chatService.saveMessage(dto, sender);

        // 2. 채팅방 구독자 전원에게 실시간 브로드캐스트
        // "/sub/chat/room/{roomId}" 를 구독 중인 클라이언트에게 전송
        // → 같은 채팅방에 접속한 양쪽이 동시에 받음
        messagingTemplate.convertAndSend(
                "/sub/chat/room/" + dto.getRoomId(),
                response
        );
    }
}