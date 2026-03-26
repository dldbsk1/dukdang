package com.example.dukdang.dto;

import com.example.dukdang.entity.TradePost;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

// 목록 조회 응답 (요약 정보만)
@Getter
@AllArgsConstructor
public class TradePostListResponseDto {
    private Long id;
    private String title;
    private int price;
    private String category;
    private String status;
    private String imageUrl; // 💡 목록은 썸네일용 1장(String)만 씁니다!
    private String sellerNickname;
    private int viewCount;
    private long wishCount;
    private LocalDateTime postTime;

    public static TradePostListResponseDto from(TradePost post, long wishCount) {

        // 💡 핵심: 사진이 여러 장이면 첫 번째 사진만 뽑고, 없으면 빈 칸 반환
        String firstImage = (post.getImageUrls() != null && !post.getImageUrls().isEmpty())
                ? post.getImageUrls().get(0) : "";

        return new TradePostListResponseDto(
                post.getId(),
                post.getTitle(),
                post.getPrice(),
                post.getCategory().name(),
                post.getStatus().name(),
                firstImage, // 💡 뽑아낸 첫 번째 사진 1장을 투입!
                post.getSeller().getNickname(),
                post.getViewCount(),
                wishCount,
                post.getPostTime()
        );
    }
}