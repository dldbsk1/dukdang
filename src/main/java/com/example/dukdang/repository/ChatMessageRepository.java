// repository/ChatMessageRepository.java
package com.example.dukdang.repository;

import com.example.dukdang.entity.ChatMessage;
import com.example.dukdang.entity.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    // 특정 채팅방의 대화 내용을 시간 순서대로(과거-현재) 가져오기
    // 특정 채팅방의 모든 메시지를 과거 -> 최신 순(오름차순)으로 조회
    List<ChatMessage> findByChatRoomOrderBySentAtAsc(ChatRoom chatRoom);
}