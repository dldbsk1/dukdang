package com.example.dukdang.dto;

import com.example.dukdang.entity.Category;
import lombok.Getter;

@Getter
public class TradePostRequestDto {
    private String title;
    private String description;
    private int price;
    private Category category;
    private String imageUrl;
}
