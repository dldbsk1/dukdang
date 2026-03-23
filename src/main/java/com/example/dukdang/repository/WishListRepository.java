package com.example.dukdang.repository;

import com.example.dukdang.entity.TradePost;
import com.example.dukdang.entity.User;
import com.example.dukdang.entity.WishList;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface WishListRepository extends JpaRepository<WishList, Long> {

    boolean existsByUserAndTradePost(User user, TradePost tradePost);
    Optional<WishList> findByUserAndTradePost(User user, TradePost tradePost);
    List<WishList> findByUserOrderByPostTimeDesc(User user);
    long countByTradePost(TradePost tradePost);
}