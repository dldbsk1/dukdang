package com.example.dukdang.dto;

import lombok.Data;
import java.util.List;

@Data
public class PostRequest {
    private String title;
    private String content;
    private int price;
    private int originalPrice;
    private int conditionScore;
    private List<String> imageUrls; // 사진 리스트 유지
    private String category;        // 카테고리 추가
    private String sellerId;
    private String status;          // SALE, RESERVED, SOLD 상태 관리
}