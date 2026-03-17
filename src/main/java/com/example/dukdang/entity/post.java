package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.apache.catalina.*;
import org.hibernate.annotations.ColumnDefault;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "trade_posts")
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)

public class post {

    // id - primary key
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 판매자 - 게시글 다수 : 사용자 한명
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @Column(nullable = false, length = 100)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private int price;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TradeStatus status;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Category category;

    private String imageUrl;

    @ColumnDefault("0")
    private int viewCount;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;
}
