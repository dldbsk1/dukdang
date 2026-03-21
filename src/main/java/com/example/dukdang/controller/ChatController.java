package com.example.dukdang.controller;

import com.example.dukdang.dto.MessageRequest;
import com.example.dukdang.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chats")
public class ChatController {
    private final ChatService chatService;

    // [이유] 사용자가 "내 채팅방 목록 좀 보여줘"라고 요청할 때 실행됩니다.
    // 서비스에게 목록을 가져오라고 시키고, 그 결과를 사용자에게 전달합니다.
    @GetMapping("/list")
    public List<Map<String, Object>> getChatList(@RequestParam String userId) throws Exception {
        return chatService.getChatList(userId);
    }

    // [이유] 특정 채팅방을 클릭했을 때, 이전의 대화 내용들을 쭉 불러오기 위해 씁니다.
    @GetMapping("/{roomId}/messages")
    public List<Map<String, Object>> getMessages(@PathVariable String roomId) throws Exception {
        return chatService.getMessages(roomId);
    }

    // [이유] 사용자가 메시지를 입력하고 '전송' 버튼을 눌렀을 때, 그 내용을 DB에 저장하기 위해 호출합니다.
    @PostMapping("/message")
    public String sendMessage(@RequestBody MessageRequest request) throws Exception {
        chatService.sendMessage(request);
        return "success";
    }
}