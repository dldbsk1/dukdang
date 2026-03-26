package com.example.dukdang.exception;

import com.example.dukdang.dto.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(CustomException.class)
    public ResponseEntity<ApiResponse<Void>> handleCustomException(CustomException e) {
        return ResponseEntity
                .status(e.getErrorCode().getStatus())
                .body(ApiResponse.fail(e.getErrorCode().getMessage()));
    }

    // 💡 [핵심 수정] 두 개로 나뉘어 있던 Exception 핸들러를 하나로 완벽하게 합쳤습니다!
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleAllExceptions(Exception e) {
        // 1. 인텔리제이 콘솔에 빨간 글씨로 진짜 원인을 출력합니다! 🚨
        System.out.println("\n🚨 [서버 에러 발생!] 🚨");
        e.printStackTrace();

        // 2. 아이폰 앱이 당황하지 않도록 기존처럼 ApiResponse 형식으로 진짜 에러 메시지를 담아서 보냅니다.
        return ResponseEntity
                .badRequest()
                .body(ApiResponse.fail("서버 오류: " + e.getMessage()));
    }
}