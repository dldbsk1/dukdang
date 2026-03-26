package com.example.dukdang.dto;

import com.example.dukdang.entity.AuctionPost;
import lombok.AllArgsConstructor;
import lombok.Getter;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@AllArgsConstructor
public class AuctionPostResponseDto {
    private Long id;
    private String title;
    private String description;
    private int minPrice;
    private Integer currentHighestPrice;
    private String category;
    private String status;
    private List<String> imageUrls;
    private String sellerNickname;
    private Long sellerId;

    // 💡 [핵심 추가] 판매자의 진짜 프로필 사진 URL을 담을 방을 만듭니다!
    private String sellerProfileImageUrl;

    private long bidCount;
    private String winnerNickname;
    private boolean isMyHighestBid;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private LocalDateTime postTime;

    public static AuctionPostResponseDto from(AuctionPost post, long bidCount, boolean isSeller, boolean isMyHighestBid) {
        boolean isEnded = post.getStatus() == com.example.dukdang.entity.AuctionStatus.ENDED
                || post.getStatus() == com.example.dukdang.entity.AuctionStatus.COMPLETED;

        Integer visiblePrice = (isSeller && !isEnded) ? null : post.getCurrentHighestPrice();
        String winnerNickname = isEnded && post.getWinner() != null ? post.getWinner().getNickname() : null;

        return new AuctionPostResponseDto(
                post.getId(),
                post.getTitle(),
                post.getDescription(),
                post.getMinPrice(),
                visiblePrice,
                post.getCategory().name(),
                post.getStatus().name(),
                post.getImageUrls(),
                post.getSeller().getNickname(),
                post.getSeller().getId(),

                // 💡 [핵심 추가] 판매자(User) 엔티티에서 저장된 프로필 사진 정보를 쏙 담습니다!
                post.getSeller().getProfileImg(),

                bidCount,
                winnerNickname,
                isMyHighestBid,
                post.getStartTime(),
                post.getEndTime(),
                post.getPostTime()
        );
    }
}