package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.TradePostListResponseDto;
import com.example.dukdang.dto.TradePostRequestDto;
import com.example.dukdang.dto.TradePostResponseDto;
import com.example.dukdang.entity.Category;
import com.example.dukdang.entity.TradeStatus;
import com.example.dukdang.entity.User;
import com.example.dukdang.service.TradePostService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/trade-posts")
@RequiredArgsConstructor
@Tag(name = "거래 게시판", description = "중고거래 게시글 API")
public class TradePostController {

    private final TradePostService tradePostService;

    // 목록 조회 — 비로그인 허용
    @GetMapping
    @Operation(summary = "목록 조회", description = "카테고리/키워드 필터 + 페이징")
    public ResponseEntity<ApiResponse<Page<TradePostListResponseDto>>> getList(
            @RequestParam(required = false) Category category,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        return ResponseEntity.ok(
                ApiResponse.ok(tradePostService.getList(category, keyword, page, size))
        );
    }

    // 단건 조회 — 비로그인 허용 (찜 여부만 null 처리)
    @GetMapping("/{id}")
    @Operation(summary = "단건 조회")
    public ResponseEntity<ApiResponse<TradePostResponseDto>> getOne(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(ApiResponse.ok(tradePostService.getOne(id, currentUser)));
    }

    // 게시글 작성 — 로그인 필수
    @PostMapping
    @Operation(summary = "게시글 작성")
    public ResponseEntity<ApiResponse<TradePostResponseDto>> create(
            @RequestBody TradePostRequestDto dto,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(tradePostService.create(dto, currentUser)));
    }

    // 게시글 수정 — 본인만
    @PutMapping("/{id}")
    @Operation(summary = "게시글 수정")
    public ResponseEntity<ApiResponse<TradePostResponseDto>> update(
            @PathVariable Long id,
            @RequestBody TradePostRequestDto dto,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(
                ApiResponse.ok(tradePostService.update(id, dto, currentUser))
        );
    }

    // 상태 변경 — 본인만 (판매중/예약중/완료)
    @PatchMapping("/{id}/status")
    @Operation(summary = "거래 상태 변경", description = "SALE / RESERVED / SOLD")
    public ResponseEntity<ApiResponse<Void>> changeStatus(
            @PathVariable Long id,
            @RequestParam TradeStatus status,
            @AuthenticationPrincipal User currentUser) {

        tradePostService.changeStatus(id, status, currentUser);
        return ResponseEntity.ok(ApiResponse.ok());
    }

    // 게시글 삭제 — 본인만
    @DeleteMapping("/{id}")
    @Operation(summary = "게시글 삭제")
    public ResponseEntity<ApiResponse<Void>> delete(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {

        tradePostService.delete(id, currentUser);
        return ResponseEntity.noContent().build();
    }

    // 찜 토글 — 로그인 필수
    @PostMapping("/{id}/wish")
    @Operation(summary = "찜 토글", description = "찜 추가/취소 자동 전환. true=찜추가, false=찜취소")
    public ResponseEntity<ApiResponse<Boolean>> toggleWish(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {

        boolean isWished = tradePostService.toggleWish(id, currentUser);
        return ResponseEntity.ok(ApiResponse.ok(isWished));
    }

    // 내 게시글 목록
    @GetMapping("/my-posts")
    @Operation(summary = "내 거래 게시글 목록")
    public ResponseEntity<ApiResponse<List<TradePostListResponseDto>>> getMyPosts(
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(ApiResponse.ok(tradePostService.getMyPosts(currentUser)));
    }

    // 내 찜 목록
    @GetMapping("/my-wishes")
    @Operation(summary = "내 찜 목록")
    public ResponseEntity<ApiResponse<List<TradePostListResponseDto>>> getMyWishes(
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(ApiResponse.ok(tradePostService.getMyWishList(currentUser)));
    }
}