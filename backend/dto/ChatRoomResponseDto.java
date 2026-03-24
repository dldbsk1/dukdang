package com.example.dukdang.dto;

import com.example.dukdang.entity.ChatRoom;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

// 채팅 목록에서 보여줄 채팅방 정보
@Getter
@AllArgsConstructor
public class ChatRoomResponseDto {
    private Long roomId;
    private Long tradePostId;
    private String tradePostTitle;
    private String tradePostImageUrl;
    private Long otherUserId;           // 상대방 id
    private String otherUserNickname;   // 상대방 닉네임
    private String lastMessage;         // 마지막 메시지 미리보기
    private LocalDateTime lastMessageAt;
    private long unreadCount;           // 안 읽은 메시지 수

    public static ChatRoomResponseDto of(ChatRoom room,
                                         String lastMessage,
                                         LocalDateTime lastMessageAt,
                                         long unreadCount,
                                         Long myId) {
        // 나를 기준으로 상대방이 누구인지 판단
        boolean iAmSeller = room.getSeller().getId().equals(myId);
        Long otherUserId = iAmSeller ? room.getBuyer().getId()
                : room.getSeller().getId();
        String otherNickname = iAmSeller ? room.getBuyer().getNickname()
                : room.getSeller().getNickname();

        // 💡 [핵심 수정] 사진 보따리에서 첫 번째 사진 1장만 쏙 빼냅니다! 사진이 없으면 빈 칸("") 처리
        String firstImage = (room.getTradePost().getImageUrls() != null && !room.getTradePost().getImageUrls().isEmpty())
                ? room.getTradePost().getImageUrls().get(0) : "";

        return new ChatRoomResponseDto(
                room.getId(),
                room.getTradePost().getId(),
                room.getTradePost().getTitle(),
                firstImage, // 💡 room.getTradePost().getImageUrl() 대신 첫 번째 사진을 넣습니다!
                otherUserId,
                otherNickname,
                lastMessage,
                lastMessageAt,
                unreadCount
        );
    }
}