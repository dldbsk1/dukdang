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
    private List<String> imageUrls; // 💡 상세 화면은 여러 장을 보여주므로 List로 변경!
    private String sellerNickname;
    private Long sellerId;
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
                post.getId(), post.getTitle(), post.getDescription(), post.getMinPrice(),
                visiblePrice, post.getCategory().name(), post.getStatus().name(),
                post.getImageUrls(), // 💡 사진 전체 리스트 전송!
                post.getSeller().getNickname(), post.getSeller().getId(),
                bidCount, winnerNickname, isMyHighestBid,
                post.getStartTime(), post.getEndTime(), post.getPostTime()
        );
    }
}