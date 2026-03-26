package com.example.dukdang.dto;

import com.example.dukdang.entity.Category;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

// 💡 [핵심 수정] @Getter 대신 @Data를 써야 스프링이 아이폰이 보낸 JSON 데이터를 완벽하게 집어넣을 수 있습니다!
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuctionPostRequestDto {
    private String title;
    private String description;
    private int minPrice;
    private Category category;
    private List<String> imageUrls;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
}