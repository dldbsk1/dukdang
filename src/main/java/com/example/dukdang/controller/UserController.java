// controller/UserController.java
package com.example.dukdang.controller;

import com.example.dukdang.dto.ApiResponse;
import com.example.dukdang.dto.LoginRequestDto;
import com.example.dukdang.dto.SignupRequestDto;
import com.example.dukdang.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    // 회원가입 API
    @PostMapping("/signup")
    public ApiResponse<Void> signup(@RequestBody SignupRequestDto request) {
        userService.signup(request);
        return ApiResponse.ok();
    }

    // 로그인 API
    @PostMapping("/login")
    public ApiResponse<String> login(@RequestBody LoginRequestDto request) {
        String token = userService.login(request); // 이제 여기서 토큰 문자열이 나옵니다.
        return ApiResponse.ok(token); // 클라이언트에게 토큰을 전달합니다.
    }
}