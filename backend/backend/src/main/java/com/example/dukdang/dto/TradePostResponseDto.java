package com.example.dukdang.dto;

import com.example.dukdang.entity.TradePost;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;
import java.util.List;

// 단건 조회 응답 (전체 정보)
@Getter
@AllArgsConstructor
public class TradePostResponseDto {
    private Long id;
    private String title;
    private String description;
    private int price;
    private String category;
    private String status;
    private List<String> imageUrls;  // 💡 상세 화면은 여러 장을 다 보여주기 위해 List를 씁니다!
    private String sellerNickname;
    private Long sellerId;
    private int viewCount;
    private long wishCount;
    private boolean isWished;        // 내가 찜했는지 여부
    private LocalDateTime postTime;

    public static TradePostResponseDto from(TradePost post, long wishCount, boolean isWished) {
        return new TradePostResponseDto(
                post.getId(),
                post.getTitle(),
                post.getDescription(), // 💡 목록엔 없는 상세 설명 포함
                post.getPrice(),
                post.getCategory().name(),
                post.getStatus().name(),
                post.getImageUrls(),   // 💡 사진 리스트 전체를 그대로 넘김!
                post.getSeller().getNickname(),
                post.getSeller().getId(), // 💡 목록엔 없는 판매자 ID 포함
                post.getViewCount(),
                wishCount,
                isWished,              // 💡 목록엔 없는 찜 여부 포함
                post.getPostTime()
        );
    }
}