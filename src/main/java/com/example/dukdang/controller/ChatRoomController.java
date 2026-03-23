package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.ChatMessageResponseDto;
import com.example.dukdang.dto.ChatRoomResponseDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.service.ChatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// REST API 담당 — 채팅방 생성/목록/메시지 히스토리 조회
// 실시간 메시지 송수신은 ChatController(WebSocket)가 담당
@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
@Tag(name = "채팅", description = "채팅방 생성 / 목록 / 이전 메시지 API")
public class ChatRoomController {

    private final ChatService chatService;

    // 채팅방 생성 or 기존 방 반환 — "채팅하기" 버튼
    @PostMapping("/rooms/trade-posts/{postId}")
    @Operation(summary = "채팅방 입장", description = "처음이면 생성, 기존 방 있으면 반환")
    public ResponseEntity<ApiResponse<ChatRoomResponseDto>> getOrCreateRoom(
            @PathVariable Long postId,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(
                ApiResponse.ok(chatService.getOrCreateRoom(postId, currentUser))
        );
    }

    // 내 채팅 목록 전체
    @GetMapping("/rooms")
    @Operation(summary = "내 채팅 목록")
    public ResponseEntity<ApiResponse<List<ChatRoomResponseDto>>> getMyChatRooms(
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(
                ApiResponse.ok(chatService.getMyChatRooms(currentUser))
        );
    }

    // 채팅방 입장 — 이전 메시지 불러오기 + 읽음 처리
    @GetMapping("/rooms/{roomId}/messages")
    @Operation(summary = "채팅방 메시지 조회", description = "입장 시 이전 메시지 + 읽음 처리")
    public ResponseEntity<ApiResponse<List<ChatMessageResponseDto>>> getMessages(
            @PathVariable Long roomId,
            @AuthenticationPrincipal User currentUser) {

        return ResponseEntity.ok(
                ApiResponse.ok(chatService.getMessages(roomId, currentUser))
        );
    }
}