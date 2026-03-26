package com.example.dukdang.service;

import com.example.dukdang.dto.AICategoryRequestDto;
import com.example.dukdang.dto.AICategoryResponseDto;
import com.example.dukdang.entity.Category;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.genai.Client;
import com.google.genai.types.Content; // 💡 AI에게 보낼 택배 상자
import com.google.genai.types.Part;    // 💡 택배 상자 안에 넣을 물건(사진, 글자)
import com.google.genai.types.GenerateContentResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Base64; // 💡 사진 변환용 도구

@Slf4j
@Service
@RequiredArgsConstructor
public class AICategoryService {

    private final Client geminiClient;
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Value("${gemini.model}")
    private String model;

    public AICategoryResponseDto analyzeCategory(AICategoryRequestDto dto) {
        String prompt = buildPrompt(dto.getTitle(), dto.getDescription());

        try {
            Content content; // AI에게 보낼 최종 택배 상자

            // 💡 만약 아이폰에서 사진을 같이 보냈다면?
            if (dto.getImageBase64() != null && !dto.getImageBase64().isEmpty()) {
                String base64Data = dto.getImageBase64();

                // 아이폰이 보낸 데이터 찌꺼기("data:image/jpeg;base64,") 잘라내기
                if (base64Data.contains(",")) {
                    base64Data = base64Data.split(",")[1];
                }

                // 사진 데이터를 컴퓨터가 읽을 수 있는 바이트(Byte)로 변환!
                byte[] imageBytes = Base64.getDecoder().decode(base64Data);

                // 상자 안에 '사진'과 '글자'를 같이 넣습니다!
                content = Content.fromParts(
                        Part.fromBytes(imageBytes, "image/jpeg"),
                        Part.fromText(prompt)
                );
                log.info("📸 사진과 텍스트를 같이 AI에게 보냅니다!");
            } else {
                // 사진이 없다면 글자만 넣습니다!
                content = Content.fromParts(Part.fromText(prompt));
                log.info("📝 텍스트만 AI에게 보냅니다!");
            }

            // AI에게 상자 전달하고 답변 받기
            GenerateContentResponse response = geminiClient.models.generateContent(model, content, null);

            String text = response.text();
            log.info("AI의 실제 답변 = {}", text);
            return parseResponse(text);

        } catch (Exception e) {
            log.error("AI 호출 실패: {}", e.getMessage());
            return new AICategoryResponseDto("ETC", "AI 분석 실패", 0.0);
        }
    }

    // AI에게 시킬 명령서 (이전과 동일)
    private String buildPrompt(String title, String description) {
        String descriptionPart = (description != null && !description.isEmpty()) ? " + 설명: \"" + description + "\"" : "";
        return """
                다음 중고거래 게시글의 제목과 설명(그리고 사진이 있다면 사진까지)을 보고, 가장 알맞은 카테고리 1개를 영문 대문자로만 골라주세요.
                
                [선택 가능한 카테고리]
                FASHION (의류/잡화)
                BOOK (서적)
                ELECTRONICS (전자기기)
                LIVING (생활용품)
                FURNITURE (자취/가구)
                FOOD (식품/간식)
                TICKET (티켓/양도)
                ASSIGNMENT (과제/자료)
                ETC (기타)
                
                게시글 제목: "%s"%s
                
                반드시 아래 JSON 형식으로만 응답하세요. 다른 말은 절대 하지 마세요.
                {"category": "카테고리명", "reason": "분류 이유 (한국어, 20자 이내)", "confidence": 0.95}
                """.formatted(title, descriptionPart);
    }

    // AI의 답변을 예쁘게 분해하는 기능 (이전과 동일)
    private AICategoryResponseDto parseResponse(String text) throws Exception {
        String cleanJson = text.replaceAll("(?s)```json\\s*", "").replaceAll("```", "").trim();
        JsonNode result = objectMapper.readTree(cleanJson);

        String category = result.path("category").asText("ETC");
        String reason = result.path("reason").asText("분석 완료");
        double confidence = result.path("confidence").asDouble(0.8);

        if (!isValidCategory(category)) {
            category = "ETC";
        }

        return new AICategoryResponseDto(category, reason, confidence);
    }

    private boolean isValidCategory(String category) {
        try {
            Category.valueOf(category);
            return true;
        } catch (IllegalArgumentException e) {
            return false;
        }
    }
}