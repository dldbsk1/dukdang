package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.ChatRoomResponseDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.repository.UserRepository;
import com.example.dukdang.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatRestController {

    private final ChatService chatService;
    private final UserRepository userRepository;

    // 💡 내 채팅 목록 가져오기 API
    @GetMapping("/rooms")
    public ResponseEntity<ApiResponse<List<ChatRoomResponseDto>>> getMyRooms(Principal principal) {
        // 현재 로그인한 유저 찾기
        User currentUser = userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // 서비스에서 목록 조회
        List<ChatRoomResponseDto> rooms = chatService.getMyChatRooms(currentUser);
        return ResponseEntity.ok(ApiResponse.ok(rooms));
    }

}