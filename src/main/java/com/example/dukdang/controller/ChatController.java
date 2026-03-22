package com.example.dukdang.controller;

import com.example.dukdang.dto.MessageRequest;
import com.example.dukdang.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.*;

/**
 * [클래스 목적] 채팅방 목록 조회, 특정 채팅방의 메시지 내역 조회, 새로운 메시지 전송 등 채팅 도메인과 관련된 API 요청을 전담하여 처리하는 컨트롤러입니다.
 */
@RestController // 반환값을 뷰(HTML)가 아닌 데이터(JSON, 문자열 등)로 클라이언트의 응답 본문(Response Body)에 직접 반환하도록 설정합니다.
@RequiredArgsConstructor // final로 선언된 필드(chatService)에 대한 생성자를 자동 생성하여, 스프링 컨테이너로부터 의존성을 주입받습니다.
@RequestMapping("/api/chats") // 이 컨트롤러 내 모든 API 엔드포인트가 공유하는 최상위 URL 경로를 지정합니다.
public class ChatController {

    // DB(Firestore) 접근 및 채팅 데이터 가공 로직을 수행할 서비스 계층 객체입니다.
    private final ChatService chatService;

    /**
     * [메서드 목적] 클라이언트로부터 특정 사용자의 아이디를 전달받아, 해당 사용자가 참여 중인 모든 채팅방 목록을 조회하여 반환합니다.
     */
    @GetMapping("/list") // HTTP GET 메서드 요청을 "/api/chats/list" 경로에 매핑하여 리소스 조회를 처리합니다.
    public List<Map<String, Object>> getChatList(
            // @RequestParam: HTTP 요청의 쿼리 파라미터(query string)에서 'userId' 값을 추출하여 바인딩합니다.
            @RequestParam String userId) throws Exception {

        // 서비스 계층의 로직을 호출하여 해당 사용자의 채팅방 목록을 가져오고, 클라이언트에게 JSON 배열 형태로 응답합니다.
        return chatService.getChatList(userId);
    }

    /**
     * [메서드 목적] 클라이언트로부터 특정 채팅방의 고유 ID를 전달받아, 해당 채팅방 내부의 전체 메시지 내역을 오름차순(시간순)으로 조회하여 반환합니다.
     */
    @GetMapping("/{roomId}/messages") // HTTP GET 메서드 요청을 "/api/chats/{roomId}/messages" 경로에 매핑합니다.
    public List<Map<String, Object>> getMessages(
            // @PathVariable: URL 경로에 포함된 변수({roomId}) 값을 추출하여 파라미터로 바인딩합니다.
            @PathVariable String roomId) throws Exception {

        // 서비스 계층의 로직을 호출하여 특정 방의 메시지 내역을 List<Map> 형태로 가져와 최종 응답합니다.
        return chatService.getMessages(roomId);
    }

    /**
     * [메서드 목적] 클라이언트가 작성한 새로운 채팅 메시지 데이터를 전달받아 DB에 저장하고 채팅방의 최신 상태를 업데이트하는 요청을 처리합니다.
     */
    @PostMapping("/message") // HTTP POST 메서드 요청을 "/api/chats/message" 경로에 매핑하여 새로운 리소스(메시지) 생성을 처리합니다.
    public String sendMessage(
            // @RequestBody: HTTP 요청 본문(Body)에 담긴 JSON 데이터를 MessageRequest 객체(DTO)로 변환하여 바인딩합니다.
            @RequestBody MessageRequest request) throws Exception {

        // 서비스 계층으로 DTO 객체를 넘겨 메시지 저장 및 방 정보 업데이트 로직을 수행합니다.
        chatService.sendMessage(request);
        // 저장이 정상적으로 완료되었음을 알리는 문자열을 반환합니다.
        return "success";
    }
}