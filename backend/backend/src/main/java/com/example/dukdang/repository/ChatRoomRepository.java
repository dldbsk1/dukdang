package com.example.dukdang.repository;

import com.example.dukdang.entity.ChatRoom;
import com.example.dukdang.entity.TradePost;
import com.example.dukdang.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {

    // 특정 게시글 + 구매자 조합으로 채팅방 찾기
    // — 이미 채팅방이 있으면 새로 만들지 않고 기존 방 반환
    Optional<ChatRoom> findByTradePostAndBuyer(TradePost tradePost, User buyer);

    // 내가 참여한 채팅방 전체 조회 (판매자 or 구매자)
    // — JPQL로 OR 조건 처리, 최신 채팅방 순
    @Query("SELECT r FROM ChatRoom r WHERE r.seller = :user OR r.buyer = :user " +
            "ORDER BY r.postTime DESC")
    List<ChatRoom> findAllByParticipant(@Param("user") User user);

    // 특정 게시글의 채팅방 목록 (판매자가 모든 구매자 채팅 보기)
    List<ChatRoom> findByTradePostOrderByPostTimeDesc(TradePost tradePost);
}