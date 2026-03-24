package com.example.dukdang.service;

import com.example.dukdang.dto.ChatMessageRequestDto;
import com.example.dukdang.dto.ChatMessageResponseDto;
import com.example.dukdang.dto.ChatRoomResponseDto;
import com.example.dukdang.entity.*;
import com.example.dukdang.exception.CustomException;
import com.example.dukdang.exception.ErrorCode;
import com.example.dukdang.repository.ChatMessageRepository;
import com.example.dukdang.repository.ChatRoomRepository;
import com.example.dukdang.repository.PostSearchRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final PostSearchRepository postSearchRepository;

    // ── 채팅방 생성 또는 기존 방 반환 ────────────────────────────
    // "채팅하기" 버튼을 누를 때 호출
    // 이미 대화한 적 있으면 기존 방으로, 처음이면 새로 생성
    public ChatRoomResponseDto getOrCreateRoom(Long postId, User buyer) {
        TradePost post = postSearchRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));

        // 자신의 게시글에 채팅 시도 방지
        if (post.getSeller().getId().equals(buyer.getId())) {
            throw new CustomException(ErrorCode.CANNOT_CHAT_WITH_SELF);
        }

        // 이미 채팅방이 있으면 그걸 반환, 없으면 새로 생성
        ChatRoom room = chatRoomRepository
                .findByTradePostAndBuyer(post, buyer)
                .orElseGet(() -> chatRoomRepository.save(ChatRoom.create(post, buyer)));

        return buildRoomResponse(room, buyer.getId());
    }

    // ── 내 채팅 목록 조회 ──────────────────────────────────────
    @Transactional(readOnly = true)
    public List<ChatRoomResponseDto> getMyChatRooms(User currentUser) {
        return chatRoomRepository.findAllByParticipant(currentUser)
                .stream()
                .map(room -> buildRoomResponse(room, currentUser.getId()))
                .toList();
    }

    // ── 채팅방 메시지 전체 조회 (입장 시 이전 대화 불러오기) ─────
    public List<ChatMessageResponseDto> getMessages(Long roomId, User currentUser) {
        ChatRoom room = findRoomOrThrow(roomId);
        checkParticipant(room, currentUser);  // 참여자인지 확인

        // 입장하면 상대방 메시지 읽음 처리
        chatMessageRepository.markAllAsRead(room, currentUser.getId());

        return chatMessageRepository.findByChatRoomOrderByPostTimeAsc(room)
                .stream()
                .map(ChatMessageResponseDto::from)
                .toList();
    }

    // ── 메시지 저장 (WebSocket으로 수신 시 호출) ──────────────
    // 저장 후 반환된 DTO를 ChatController가 구독자에게 브로드캐스트
    public ChatMessageResponseDto saveMessage(ChatMessageRequestDto dto, User sender) {
        ChatRoom room = findRoomOrThrow(dto.getRoomId());
        checkParticipant(room, sender);

        ChatMessage message = ChatMessage.create(room, sender, dto.getContent());
        ChatMessage saved = chatMessageRepository.save(message);
        return ChatMessageResponseDto.from(saved);
    }

    // ── 공통 헬퍼 ─────────────────────────────────────────────
    private ChatRoom findRoomOrThrow(Long roomId) {
        return chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new CustomException(ErrorCode.CHAT_ROOM_NOT_FOUND));
    }

    // 채팅방 참여자가 아닌 제3자 접근 차단
    private void checkParticipant(ChatRoom room, User user) {
        if (!room.isParticipant(user)) {
            throw new CustomException(ErrorCode.CHAT_FORBIDDEN);
        }
    }

    // ChatRoom → ChatRoomResponseDto 변환
    // 마지막 메시지, 안읽음 수를 함께 조회해서 채팅 목록 미리보기 완성
    private ChatRoomResponseDto buildRoomResponse(ChatRoom room, Long myId) {
        List<ChatMessage> lastMsgList =
                chatMessageRepository.findTop1ByChatRoomOrderByPostTimeDesc(room);

        String lastMessage = lastMsgList.isEmpty() ? "" : lastMsgList.get(0).getContent();
        var lastMessageAt = lastMsgList.isEmpty() ? room.getPostTime()
                : lastMsgList.get(0).getPostTime();
        long unreadCount = chatMessageRepository.countUnreadMessages(room, myId);

        return ChatRoomResponseDto.of(room, lastMessage, lastMessageAt, unreadCount, myId);
    }
}