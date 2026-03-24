package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.apache.catalina.*;
import org.hibernate.annotations.ColumnDefault;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "trade_posts")
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)

public class TradePost {

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

    // 💡 [수정] 여러 장의 사진 URL을 저장할 리스트로 변경!
    @ElementCollection
    @CollectionTable(name = "trade_post_images", joinColumns = @JoinColumn(name = "post_id"))
    @Column(name = "image_url")
    private List<String> imageUrls;

    @ColumnDefault("0")
    private int viewCount;

    // 게시글 생성 시간
    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;

    // 게시글 생성 메서드
    public static TradePost create(User seller, String title, String description,
                                   int price, Category category, List<String> imageUrls ) {
        TradePost post = new TradePost();
        post.seller = seller;
        post.title = title;
        post.description = description;
        post.price = price;
        post.category = category;
        post.imageUrls = imageUrls;
        post.status = TradeStatus.SALE;
        post.viewCount = 0;

        return post;
    }

    // 게시글 수정
    public void update(String title, String description, int price, Category category, List<String> imageUrls) {
        this.title = title;
        this.description = description;
        this.price = price;
        this.category = category;
        this.imageUrls = imageUrls;
    }

    // 판매 상태 변경
    public void changeStatus(TradeStatus status) {
        this.status = status;
    }

    // 조회수 증가 캡슐화
    public void addViewCount() {
        this.viewCount++;
    }
}
