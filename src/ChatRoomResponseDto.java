// dto/ChatRoomResponseDto.java
package com.example.dukdang.dto;

import com.example.dukdang.entity.ChatRoom;
import lombok.AllArgsConstructor;
import lombok.Getter;
import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ChatRoomResponseDto {
    private Long roomId;
    private Long postId;
    private String postTitle;
    private String opponentName; // 상대방 이름
    private String lastMessage;
    private LocalDateTime lastTimestamp;

    // 필요한 정보만 골라 담는 바구니
    // 상대방 닉네임, 마지막 메시지 등만 담기 - 채팅 목록 화면에 필요한 정보
    public static ChatRoomResponseDto from(ChatRoom room, Long currentUserId) {
        // 내가 구매자면 판매자가 상대방, 내가 판매자면 구매자가 상대방
        String opponentName = room.getBuyer().getId().equals(currentUserId)
                ? room.getSeller().getNickname()
                : room.getBuyer().getNickname();

        // 채팅창 안에서 보일 메시지 정보를 담는다
        return new ChatRoomResponseDto(
                room.getId(),
                room.getTradePost().getId(),
                room.getTradePost().getTitle(),
                opponentName,
                room.getLastMessage(),
                room.getLastTimestamp()
        );
    }
}