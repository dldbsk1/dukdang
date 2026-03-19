package com.example.dukdang.repository;

import com.example.dukdang.entity.TradePost;
import com.example.dukdang.entity.WishList;
import org.apache.catalina.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

// repository/WishListRepository.java
public interface WishListRepository extends JpaRepository<WishList, Long> {

    // 이미 찜했는지 확인
    boolean existsByUserAndTradePost(User user, TradePost tradePost);

    // 찜 취소용 조회
    Optional<WishList> findByUserAndTradePost(User user, TradePost tradePost);

    // 내 찜 목록
    List<WishList> findByUserOrderByCreatedAtDesc(User user);

    // 특정 게시글의 찜 수
    long countByTradePost(TradePost tradePost);
}