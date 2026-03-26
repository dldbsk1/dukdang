package com.example.dukdang.service;

import com.example.dukdang.dto.AICategoryRequestDto;
import com.example.dukdang.dto.AICategoryResponseDto;
import com.example.dukdang.entity.Category;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.genai.Client;
import com.google.genai.types.GenerateContentResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Arrays;

@Slf4j
@Service
@RequiredArgsConstructor
public class AICategoryService {

    private final Client geminiClient;    // AiConfig에서 주입
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${gemini.model}")
    private String model;

    public AICategoryResponseDto analyzeCategory(AICategoryRequestDto dto) {
        String prompt = buildPrompt(dto.getTitle(), dto.getDescription());

        try {
            // ChatClient.builder(model).build() 와 동일한 심플함
            GenerateContentResponse response = geminiClient.models.generateContent(model, prompt, null);

            String text = response.text();  // 응답 텍스트 바로 꺼내기
            log.info("Gemini raw response = {}", text);
            return parseResponse(text);

        } catch (Exception e) {
            log.error("Gemini API 호출 실패: {}", e.getMessage());
            return new AICategoryResponseDto("ETC", "AI 분석에 실패했습니다.", 0.0);
        }
    }

    private String buildPrompt(String title, String description) {
        String descriptionPart = (description != null && !description.isBlank()) ? "\n상품 설명: " + description : "";

        return """
                당신은 중고거래 플랫폼의 카테고리 분류 전문가입니다.
                상품 제목과 설명을 분석해서 아래 6가지 카테고리 중 하나로 분류하세요.
                
                카테고리 목록:
                - ELECTRONICS: 전자기기 (스마트폰, 노트북, 태블릿, 카메라, 이어폰, 게임기 등)
                - FASHION: 패션/의류 (옷, 신발, 가방, 시계, 액세서리 등)
                - FURNITURE: 가구/인테리어 (책상, 의자, 침대, 조명, 자취용품 등)
                - BOOK: 도서/문구 (책, 교재, 문제집, 만화책, 문구류 등)
                - LIVING: 생활용품 (주방용품, 욕실용품, 청소용품 등 생필품)
                - FOOD: 식품/간식 (음료, 과자, 냉동식품 등)
                - TICKET: 티켓/양도 (공연, 영화, 쿠폰, 기프티콘, 이용권 등)
                - ASSIGNMENT: 과제/자료 (강의자료, 족보, 발표자료, 팀플 자료, ppt 등)
                - ETC: 위에 해당하지 않는 경우
                
                상품 제목: %s
                상품 설명: %s
                
                반드시 아래 JSON 형식으로만 응답하세요. 다른 말은 절대 하지 마세요.
                {"category": "카테고리명", "reason": "분류 이유 (한국어, 20자 이내)", "confidence": 0.95}
                
                예시:
                입력: "아이폰 15 Pro 256GB 미개봉"
                출력: {"category": "ELECTRONICS", "reason": "스마트폰 제품", "confidence": 0.99}
                
                입력: "나이키 에어포스 270mm 거의 새것"
                출력: {"category": "FASHION", "reason": "신발 제품", "confidence": 0.97}
                
                입력: "팝니다" + 설명: "트레킹화 260mm 2회 착용"
                출력: {"category": "FASHION", "reason": "등산화 제품", "confidence": 0.95}
                """.formatted(title, descriptionPart);
    }

    private AICategoryResponseDto parseResponse(String text) throws Exception {
        String cleanJson = text.replaceAll("(?s)```json\\s*", "").replaceAll("```", "").trim();

        JsonNode result = objectMapper.readTree(cleanJson);

        String category = result.path("category").asText("ETC");
        String reason = result.path("reason").asText("분석 완료");
        double confidence = result.path("confidence").asDouble(0.8);

        if (!isValidCategory(category)) {
            log.warn("Gemini가 잘못된 카테고리 반환: {}", category);
            category = "ETC";
        }

        return new AICategoryResponseDto(category, reason, confidence);
    }

    private boolean isValidCategory(String category) {
        return Arrays.stream(Category.values()).anyMatch(c -> c.name().equals(category));
    }
}