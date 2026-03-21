// controller/ChatController.java
package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.ChatMessageResponseDto;
import com.example.dukdang.dto.ChatRoomResponseDto;
import com.example.dukdang.dto.MessageRequestDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chats")
/*GET /api/chats/list: "내 채팅방 목록 다 보여줘."
POST /api/chats/{roomId}/messages: "이 방에 메시지 하나 보내줘."
GET /api/chats/{roomId}/messages: "이 방에서 나눈 대화들 다 보여줘."*/
public class ChatController {

    private final ChatService chatService;

    // 내 채팅 목록 불러오기
    @GetMapping("/list")
    public ApiResponse<List<ChatRoomResponseDto>> getChatList(
            /* @AuthenticationPrincipal User currentUser 처럼 로그인된 사용자 정보를 받아야 합니다 */
            User currentUser
    ) {
        List<ChatRoomResponseDto> chatList = chatService.getChatList(currentUser);
        return ApiResponse.ok(chatList);
    }

    // 메시지 전송
    @PostMapping("/{roomId}/messages")
    public ApiResponse<Void> sendMessage(
            @PathVariable Long roomId,
            @RequestBody MessageRequestDto request,
            User currentUser
    ) {
        chatService.sendMessage(roomId, request, currentUser);
        return ApiResponse.ok();
    }

    // 특정 방 대화 내역 불러오기
    @GetMapping("/{roomId}/messages")
    public ApiResponse<List<ChatMessageResponseDto>> getMessages(
            @PathVariable Long roomId,
            User currentUser
    ) {
        List<ChatMessageResponseDto> messages = chatService.getMessages(roomId, currentUser);
        return ApiResponse.ok(messages);
    }
}
/*채팅 시작: 구매자가 게시글에서 '채팅하기'를 누르면 createRoom이 호출되어 방이 생깁니다.
목록 확인: 사용자가 채팅 탭을 누르면 getChatList를 통해 내가 참여한 방들이 마지막 메시지와 함께 쭉 뜹니다.
대화 입장: 특정 방을 클릭하면 getMessages가 호출되어 과거 대화 내역이 화면에 뿌려집니다.
메시지 전송: 입력창에 글을 쓰고 전송을 누르면 sendMessage가 동작하여 상대방에게 전달될 준비를 마치고 DB에 기록됩니다.*/