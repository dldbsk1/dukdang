package com.example.dukdang.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker  // STOMP 메시지 브로커 활성화
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // 구독 경로 접두사
        // 클라이언트가 "/sub/chat/room/1" 구독 → 채팅방 1의 메시지 수신
        registry.enableSimpleBroker("/sub");

        // 발행 경로 접두사
        // 클라이언트가 "/pub/chat/message" 로 메시지 전송
        registry.setApplicationDestinationPrefixes("/pub");
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // WebSocket 연결 엔드포인트
        // 클라이언트가 ws://localhost:8080/ws-chat 으로 최초 연결
        // withSockJS() : WebSocket 미지원 브라우저를 위한 폴백 옵션
        registry.addEndpoint("/ws-chat")
                .setAllowedOriginPatterns("*")  // 개발 중엔 전체 허용, 운영 시 도메인 지정
                .withSockJS();
    }
}