package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.LoginRequestDto;
import com.example.dukdang.dto.LoginResponseDto;
import com.example.dukdang.dto.SignupRequestDto;
import com.example.dukdang.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "인증", description = "회원가입 / 로그인 API")
public class AuthController {

    // 스프링이 주입해주는 authService 객체 (소문자 a)
    private final AuthService authService;

    @PostMapping("/signup")
    @Operation(summary = "회원가입")
    public ResponseEntity<ApiResponse<Void>> signup(@RequestBody SignupRequestDto dto) {
        authService.signup(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok());
    }

    @PostMapping("/login")
    @Operation(summary = "로그인", description = "성공 시 JWT 토큰과 유저 ID 반환")
    // 💡 타입을 <String>에서 <LoginResponseDto>로 변경합니다!
    public ResponseEntity<ApiResponse<LoginResponseDto>> login(@RequestBody LoginRequestDto dto) {

        // 💡 이제 반환값이 String이 아니라 DTO 상자입니다.
        LoginResponseDto loginResponse = authService.login(dto);

        // 💡 상자(loginResponse)를 그대로 담아서 내려보냅니다.
        return ResponseEntity.ok(ApiResponse.ok(loginResponse));
    }

    @GetMapping("/check-email")
    public ResponseEntity<Map<String, Boolean>> checkEmail(@RequestParam String email) {
        // AuthService의 checkEmail 호출
        boolean isAvailable = authService.checkEmail(email);

        // {"available": true} 형태로 iOS에 응답
        Map<String, Boolean> response = new HashMap<>();
        response.put("available", isAvailable);

        return ResponseEntity.ok(response);
    }
}