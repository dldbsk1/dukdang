// repository/ChatRoomRepository.java
package com.example.dukdang.repository;

import com.example.dukdang.entity.ChatRoom;
import com.example.dukdang.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    // 내가 구매자이거나 판매자인 채팅방 목록 조회 (최신순
    //채팅방 목록을 최신순으로 가져와
    List<ChatRoom> findByBuyerOrSellerOrderByLastTimestampDesc(User buyer, User seller);
}