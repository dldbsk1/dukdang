package com.example.dukdang.dto;

import lombok.Data;
import java.util.List;

@Data
public class PostRequest {
    private String title;
    private String content;
    private int price;
    private int originalPrice;
    private int conditionScore; // 1-5 사이 체크
    private List<String> imageUrls; // 사진 URL들
    private String sellerId;
}
