package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.LoginRequestDto;
import com.example.dukdang.dto.SignupRequestDto;
import com.example.dukdang.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "인증", description = "회원가입 / 로그인 API")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/signup")
    @Operation(summary = "회원가입")
    public ResponseEntity<ApiResponse<Void>> signup(@RequestBody SignupRequestDto dto) {
        authService.signup(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok());
    }

    @PostMapping("/login")
    @Operation(summary = "로그인", description = "성공 시 JWT 토큰 반환")
    public ResponseEntity<ApiResponse<String>> login(@RequestBody LoginRequestDto dto) {
        String token = authService.login(dto);
        return ResponseEntity.ok(ApiResponse.ok(token));
    }
}