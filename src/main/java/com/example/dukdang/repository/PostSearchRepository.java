package com.example.dukdang.repository;

import com.example.dukdang.entity.Category;
import com.example.dukdang.entity.TradePost;
import com.example.dukdang.entity.TradeStatus;
import org.apache.catalina.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface PostSearchRepository extends JpaRepository<TradePost, Long> {

    // 조회
    Page<TradePost> findByCategoryOrderByPostTimeDesc(Category category, Pageable pageable);
    Page<TradePost> findByTitleContainingOrderByPostTimeDesc(String keyword, Pageable pageable);
    List<TradePost> findBySellerOrderByPostTimeDesc(User seller);
    Page<TradePost> findByStatusOrderByPostTimeDesc(TradeStatus status, Pageable pageable);

    // 카테고리 + 상태
    @Query("SELECT t FROM TradePost t WHERE " +
            "(:category IS NULL OR t.category = :category) AND " +
            "(:keyword IS NULL OR t.title LIKE %:keyword%) " +
            "ORDER BY t.createdAt DESC")
    Page<TradePost> search(@Param("category") Category category,
                           @Param("keyword") String keyword,
                           Pageable pageable);
}
