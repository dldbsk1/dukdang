package com.example.dukdang.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor // 💡 안전장치: 스프링(Jackson)이 빈 박스를 먼저 만들 수 있게 해줌
@AllArgsConstructor // 💡 안전장치: 모든 값을 한 번에 채울 수 있게 해줌
public class AICategoryRequestDto {
    private String title;          // 게시글 제목
    private String description;    // 본문
    private String imageBase64;    // 💡 [추가] 아이폰이 보낸 사진 데이터!
}