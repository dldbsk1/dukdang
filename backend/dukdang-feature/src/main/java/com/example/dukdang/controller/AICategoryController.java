package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.AICategoryRequestDto;
import com.example.dukdang.dto.AICategoryResponseDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.service.AICategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
@Tag(name = "AI", description = "AI 카테고리 자동 분류 (Gemini)")
public class AICategoryController {

    private final AICategoryService aiCategoryService;

    @PostMapping("/category")
    @Operation(
            summary = "AI 카테고리 자동 분류",
            description = "제목과 본문을 분석해서 카테고리를 추천합니다. " +
                    "description이 있으면 더 정확하게 분류됩니다."
    )
    public ResponseEntity<ApiResponse<AICategoryResponseDto>> analyzeCategory(
            @RequestBody AICategoryRequestDto dto,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(
                ApiResponse.ok(aiCategoryService.analyzeCategory(dto))
        );
    }
}