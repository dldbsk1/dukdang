// service/ChatService.java
package com.example.dukdang.service;

import com.example.dukdang.dto.*;
import com.example.dukdang.entity.*;
import com.example.dukdang.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional
public class ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final UserRepository userRepository;
    private final PostSearchRepository postRepository;

    // 1. 채팅방 목록 가져오기
    @Transactional(readOnly = true)
    public List<ChatRoomResponseDto> getChatList(User currentUser) {
        return chatRoomRepository.findByBuyerOrSellerOrderByLastTimestampDesc(currentUser, currentUser)
                .stream()
                .map(room -> ChatRoomResponseDto.from(room, currentUser.getId()))
                .collect(Collectors.toList());
    }

    // 2. 메시지 보내기
    // 메시지를 데이터베이스에 저장, 동시에 해당 채팅방의 lastMessage를 방금 보낸 내용으로 업데이트
    // 이때 JPA의 변경감지 기능을 사용하여 자동으로 DB에 반영
    // 목록 및 내역 조회: 참여 중인 방 목록을 가져오거나 특정 방의 메시지들을 긁어오기
    public void sendMessage(Long roomId, MessageRequestDto request, User sender) {
        ChatRoom room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방을 찾을 수 없습니다."));

        // 메시지 생성 및 저장
        ChatMessage message = ChatMessage.create(room, sender, request.getContent());
        chatMessageRepository.save(message);

        // 채팅방의 마지막 메시지 업데이트 (JPA 변경 감지 활용)
        room.updateLastMessage(request.getContent());
    }

    // (참고용) 새로운 채팅방 생성 로직
    // 게시글 ID와 구매자 정보를 받아 새로운 방을 만든다
    public Long createRoom(Long postId, User buyer) {
        TradePost post = postRepository.findById(postId).orElseThrow();
        ChatRoom newRoom = ChatRoom.create(buyer, post.getSeller(), post);
        return chatRoomRepository.save(newRoom).getId();
    }

    // 특정 채팅방의 메시지 내역 가져오기
    @Transactional(readOnly = true)
    public List<ChatMessageResponseDto> getMessages(Long roomId, User currentUser) {
        ChatRoom room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방을 찾을 수 없습니다."));

        // (선택) 현재 사용자가 이 채팅방의 참여자(구매자 or 판매자)인지 권한 체크 로직을 넣으면 더 안전합니다!

        return chatMessageRepository.findByChatRoomOrderBySentAtAsc(room)
                .stream()
                .map(ChatMessageResponseDto::from)
                .toList();
    }
}