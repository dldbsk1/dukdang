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
    private Long tradePostId;       // (iOS 호환을 위해 이름 유지)
    private String tradePostTitle;  // (iOS 호환을 위해 이름 유지)
    private String tradePostImageUrl;
    private Long otherUserId;
    private String otherUserNickname;
    private String otherUserProfileImage; // 💡 [추가됨] 상대방 프로필 사진 URL!
    private String lastMessage;
    private LocalDateTime lastMessageAt;
    private long unreadCount;

    public static ChatRoomResponseDto of(ChatRoom room,
                                         String lastMessage,
                                         LocalDateTime lastMessageAt,
                                         long unreadCount,
                                         Long myId) {

        boolean iAmSeller = room.getSeller().getId().equals(myId);
        Long otherUserId = iAmSeller ? room.getBuyer().getId() : room.getSeller().getId();
        String otherNickname = iAmSeller ? room.getBuyer().getNickname() : room.getSeller().getNickname();

        // 💡 [추가됨] 내가 판매자면 구매자 프사를, 내가 구매자면 판매자 프사를 가져옵니다!
        String otherProfileImg = iAmSeller ? room.getBuyer().getProfileImg() : room.getSeller().getProfileImg();

        return new ChatRoomResponseDto(
                room.getId(),
                room.getPostId(),       // 일반이든 경매든 알아서 ID 꺼냄
                room.getPostTitle(),    // 알아서 제목 꺼냄
                room.getPostImageUrl(), // 알아서 첫 번째 사진 꺼냄
                otherUserId,
                otherNickname,
                otherProfileImg,        // 💡 상대방 프로필 사진 세팅
                lastMessage,
                lastMessageAt,
                unreadCount
        );
    }
}