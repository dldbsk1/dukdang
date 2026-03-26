package com.example.dukdang.dto;

import com.example.dukdang.entity.WishList;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class WishListResponseDto {
    private Long id; // 찜 고유 번호
    private WishPostResponseDto tradePost; // 💡 엔티티 대신 DTO를 담아 순환 참조 방지

    public static WishListResponseDto from(WishList wishList) {
        return new WishListResponseDto(
                wishList.getId(),
                WishPostResponseDto.from(wishList.getTradePost())
        );
    }
}
