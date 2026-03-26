package com.example.dukdang.dto;

import com.example.dukdang.entity.Category;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.util.List;

@Getter
@Setter // 💡 필수 추가: 데이터를 집어넣기 위해 필요합니다.
@NoArgsConstructor // 💡 필수 추가: 스프링이 데이터를 매핑할 때 기본 생성자가 꼭 필요합니다.
@AllArgsConstructor
public class TradePostRequestDto {
    private String title;
    private String description;
    private int price;
    private Category category;
    private List<String> imageUrls;
}
