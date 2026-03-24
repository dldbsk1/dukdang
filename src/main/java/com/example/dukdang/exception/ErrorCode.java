package com.example.dukdang.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    // 회원
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),
    DUPLICATE_EMAIL(HttpStatus.CONFLICT, "이미 사용 중인 이메일입니다."),
    INVALID_PASSWORD(HttpStatus.UNAUTHORIZED, "비밀번호가 올바르지 않습니다."),

    // 게시글
    POST_NOT_FOUND(HttpStatus.NOT_FOUND, "게시글을 찾을 수 없습니다."),
    FORBIDDEN(HttpStatus.FORBIDDEN, "권한이 없습니다."),

    // 채팅
    CHAT_ROOM_NOT_FOUND(HttpStatus.NOT_FOUND, "채팅방을 찾을 수 없습니다."),
    CHAT_FORBIDDEN(HttpStatus.FORBIDDEN, "채팅방 접근 권한이 없습니다."),
    CANNOT_CHAT_WITH_SELF(HttpStatus.BAD_REQUEST, "자신의 게시글에는 채팅할 수 없습니다."),

    // 경매
    AUCTION_NOT_FOUND(HttpStatus.NOT_FOUND, "경매를 찾을 수 없습니다."),
    AUCTION_NOT_ACTIVE(HttpStatus.BAD_REQUEST, "진행 중인 경매가 아닙니다."),
    BID_PRICE_TOO_LOW(HttpStatus.BAD_REQUEST, "현재 최고 입찰가보다 높게 입찰해야 합니다."),
    CANNOT_BID_OWN_AUCTION(HttpStatus.BAD_REQUEST, "본인의 경매에는 입찰할 수 없습니다."),
    AUCTION_NOT_ENDED(HttpStatus.BAD_REQUEST, "경매가 아직 종료되지 않았습니다.");

    private final HttpStatus status;
    private final String message;
}