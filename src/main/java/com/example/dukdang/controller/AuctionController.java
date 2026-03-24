package com.example.dukdang.controller;

import com.example.dukdang.dto.*;
import com.example.dukdang.entity.Category;
import com.example.dukdang.entity.User;
import com.example.dukdang.service.AuctionService;
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
@RequestMapping("/auctions")
@RequiredArgsConstructor
@Tag(name = "경매", description = "경매 게시글 + 입찰 API")
public class AuctionController {

    private final AuctionService auctionService;

    // 경매 목록 — 비로그인 가능
    @GetMapping
    @Operation(summary = "경매 목록 조회")
    public ResponseEntity<ApiResponse<Page<AuctionPostListResponseDto>>> getList(
            @RequestParam(required = false) Category category,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        return ResponseEntity.ok(
                ApiResponse.ok(auctionService.getList(category, keyword, page, size))
        );
    }

    // 경매 단건 조회 — 로그인 필수 (판매자/구매자 구분 필요)
    @GetMapping("/{id}")
    @Operation(summary = "경매 단건 조회",
            description = "판매자: 진행중 입찰가 숨김 / 구매자: 현재 최고가 + 최고입찰자 여부")
    public ResponseEntity<ApiResponse<AuctionPostResponseDto>> getOne(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(ApiResponse.ok(auctionService.getOne(id, currentUser)));
    }

    // 경매 등록
    @PostMapping
    @Operation(summary = "경매 등록")
    public ResponseEntity<ApiResponse<AuctionPostResponseDto>> create(
            @RequestBody AuctionPostRequestDto dto,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(auctionService.create(dto, currentUser)));
    }

    // 입찰
    @PostMapping("/bid")
    @Operation(summary = "입찰", description = "현재 최고가보다 높게만 입찰 가능. 여러 번 입찰 가능")
    public ResponseEntity<ApiResponse<AuctionBidResponseDto>> bid(
            @RequestBody AuctionBidRequestDto dto,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok(auctionService.bid(dto, currentUser)));
    }

    // 내 입찰 내역 (특정 경매에서)
    @GetMapping("/{id}/my-bids")
    @Operation(summary = "내 입찰 내역 조회")
    public ResponseEntity<ApiResponse<List<AuctionBidResponseDto>>> getMyBids(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(ApiResponse.ok(auctionService.getMyBids(id, currentUser)));
    }

    // 내가 등록한 경매 목록
    @GetMapping("/my-auctions")
    @Operation(summary = "내 경매 목록")
    public ResponseEntity<ApiResponse<List<AuctionPostListResponseDto>>> getMyAuctions(
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(ApiResponse.ok(auctionService.getMyAuctions(currentUser)));
    }

    // 거래 완료 처리
    @PatchMapping("/{id}/complete")
    @Operation(summary = "거래 완료", description = "낙찰자 또는 판매자가 완료 처리")
    public ResponseEntity<ApiResponse<Void>> complete(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {

        auctionService.complete(id, currentUser);
        return ResponseEntity.ok(ApiResponse.ok());
    }
}