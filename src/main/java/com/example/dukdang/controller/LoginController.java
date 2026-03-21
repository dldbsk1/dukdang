package com.example.dukdang.controller;

import com.example.dukdang.dto.UserResponse;
import com.example.dukdang.service.LoginService;
import lombok.RequiredArgsConstructor; // 이걸 쓰면 코드가 훨씬 깔끔해져요
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequiredArgsConstructor // 생성자 주입을 자동으로 해줍니다
public class LoginController {

    private final LoginService loginService; // 필드 주입(@Autowired)보다 이게 더 안전

    @PostMapping("/login")
    public UserResponse login(@RequestBody Map<String, String> data) throws Exception {
        // 컨트롤러는 "요청 받고 응답 주는" 역할만!
        // 실제 로직은 Service한테 시키는 게 정석입니다.
        return loginService.authenticate(data.get("userId"), data.get("password"));
    }
}