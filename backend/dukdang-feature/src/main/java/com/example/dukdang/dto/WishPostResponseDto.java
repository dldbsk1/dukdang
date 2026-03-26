package com.example.dukdang.dto;

import com.example.dukdang.entity.TradePost;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class WishPostResponseDto {
    private Long id;
    private String title;
    private Integer price;
    private String imageName;
    private String category;
    private String sellerNickname;

    public static WishPostResponseDto from(TradePost post) {

        // 💡 [핵심 수정] 사진 리스트에서 첫 번째 사진 1장만 쏙 빼냅니다! 사진이 없으면 빈 칸("") 처리
        String firstImage = (post.getImageUrls() != null && !post.getImageUrls().isEmpty())
                ? post.getImageUrls().get(0) : "";

        return new WishPostResponseDto(
                post.getId(),
                post.getTitle(),
                post.getPrice(),
                firstImage, // 💡 post.getImageUrls() 대신 뽑아낸 첫 번째 사진을 넣습니다!
                // 💡 [안전장치] 카테고리가 null이면 "기타"로 표시
                post.getCategory() != null ? post.getCategory().name() : "기타",
                // 💡 [안전장치] 판매자가 null이면 "알 수 없음"으로 표시
                post.getSeller() != null ? post.getSeller().getNickname() : "알 수 없음"
        );
    }
}