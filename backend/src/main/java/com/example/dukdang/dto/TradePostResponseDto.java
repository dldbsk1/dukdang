package com.example.dukdang.dto;

import com.example.dukdang.entity.TradePost;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@AllArgsConstructor
public class TradePostResponseDto {
    private Long id;
    private String title;
    private String description;
    private int price;
    private String category;
    private String status;
    private List<String> imageUrls;
    private String sellerNickname;
    private Long sellerId;
    private String sellerProfileImageUrl; // 💡 [핵심 추가] 판매자 프사 주소 방을 만들었습니다!
    private int viewCount;
    private long wishCount;
    private boolean isWished;
    private LocalDateTime postTime;

    public static TradePostResponseDto from(TradePost post, long wishCount, boolean isWished) {
        return new TradePostResponseDto(
                post.getId(),
                post.getTitle(),
                post.getDescription(),
                post.getPrice(),
                post.getCategory().name(),
                post.getStatus().name(),
                post.getImageUrls(),
                post.getSeller().getNickname(),
                post.getSeller().getId(),
                post.getSeller().getProfileImg(), // 💡 [핵심 추가] DB에서 진짜 프사 주소를 꺼내 담습니다!
                post.getViewCount(),
                wishCount,
                isWished,
                post.getPostTime()
        );
    }
}