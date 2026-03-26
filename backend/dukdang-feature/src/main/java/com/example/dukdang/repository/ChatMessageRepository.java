package com.example.dukdang.repository;

import com.example.dukdang.entity.ChatMessage;
import com.example.dukdang.entity.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {

    // 채팅방의 전체 메시지 (오래된 것부터 — 채팅창은 위에서 아래로 읽음)
    List<ChatMessage> findByChatRoomOrderByPostTimeAsc(ChatRoom chatRoom);

    // 채팅방의 마지막 메시지 1개 (채팅 목록에서 미리보기 용)
    // — List로 받아서 첫 번째 꺼냄 (Optional 처리 간편하게)
    List<ChatMessage> findTop1ByChatRoomOrderByPostTimeDesc(ChatRoom chatRoom);

    // 안 읽은 메시지 수 (채팅 목록 뱃지 숫자)
    // — sender가 나 자신이 아닌 메시지 중 읽지 않은 것
    @Query("SELECT COUNT(m) FROM ChatMessage m WHERE m.chatRoom = :room " +
            "AND m.sender.id != :userId AND m.isRead = false")
    long countUnreadMessages(@Param("room") ChatRoom room,
                             @Param("userId") Long userId);

    // 채팅방 입장 시 상대방이 보낸 미읽 메시지 일괄 읽음 처리
    // @Modifying: SELECT가 아닌 UPDATE/DELETE 쿼리임을 명시
    // clearAutomatically: 영속성 컨텍스트 캐시를 비워서 변경 내용 즉시 반영
    @Modifying(clearAutomatically = true)
    @Query("UPDATE ChatMessage m SET m.isRead = true WHERE m.chatRoom = :room " +
            "AND m.sender.id != :userId AND m.isRead = false")
    void markAllAsRead(@Param("room") ChatRoom room,
                       @Param("userId") Long userId);
}