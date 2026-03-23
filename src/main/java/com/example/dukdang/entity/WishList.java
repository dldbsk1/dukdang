package com.example.dukdang.entity;

import lombok.Getter;
import lombok.NoArgsConstructor;
import jakarta.persistence.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "wish_lists",
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "trade_post_id"})
        // DB 레벨에서 같은 유저가 같은 글을 두 번 찜하는 걸 방지
)
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class WishList {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trade_post_id", nullable = false)
    private TradePost tradePost;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;

    public static WishList create(User user, TradePost tradePost) {
        WishList wishList = new WishList();
        wishList.user = user;
        wishList.tradePost = tradePost;
        return wishList;
    }
}