package com.example.dukdang.controller;

import com.example.dukdang.dto.UserResponse;
import com.example.dukdang.service.LoginService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

/**
 * [클래스 목적] 사용자의 회원가입 및 로그인과 관련된 인증 API 요청을 전담하여 처리하는 컨트롤러입니다.
 */
@RestController // 메서드의 반환값을 뷰(HTML)가 아닌 데이터(JSON, 문자열 등)로 클라이언트의 응답 본문(Response Body)에 직접 반환하도록 설정합니다.
@RequiredArgsConstructor // final로 선언된 필드(loginService)에 대한 생성자를 자동 생성하여, 스프링 컨테이너로부터 의존성을 주입받습니다.
public class LoginController {

    // DB(Firestore) 접근 및 회원가입/로그인 비즈니스 로직을 수행할 서비스 계층 객체입니다.
    private final LoginService loginService;

    /**
     * [메서드 목적] 클라이언트가 보낸 사용자 정보 데이터를 받아 새로운 회원 계정을 생성(등록)하는 요청을 처리합니다.
     */
    @PostMapping("/register") // HTTP POST 메서드 요청을 "/register" 경로에 매핑하여 새로운 리소스(회원 정보) 생성을 처리합니다.
    public String register(
            // @RequestBody: HTTP 요청 본문(Body)에 담긴 JSON 데이터를 UserResponse 객체(DTO)로 변환하여 바인딩합니다.
            @RequestBody UserResponse request) throws Exception {

        // 서비스 계층으로 DTO 객체를 넘겨 중복 확인 및 DB 저장 로직을 수행하고, 결과(성공 또는 중복 상태) 문자열을 반환합니다.
        return loginService.register(request);
    }

    /**
     * [메서드 목적] 클라이언트가 보낸 아이디와 비밀번호를 받아, DB 데이터와 대조하여 회원 인증을 수행하는 요청을 처리합니다.
     */
    @PostMapping("/login") // HTTP POST 메서드 요청을 "/login" 경로에 매핑하여 인증 처리를 수행합니다. (보안을 위해 GET 대신 POST 사용)
    public UserResponse login(
            // @RequestBody: HTTP 요청 본문에 담긴 JSON 데이터를 Map<String, String> 형태(키-값 쌍)로 변환하여 바인딩합니다.
            @RequestBody Map<String, String> data) throws Exception {

        // Map에서 "userId"와 "password" 키에 해당하는 값을 추출하여 서비스 계층의 인증 로직으로 전달합니다.
        // 인증 성공 시 해당 사용자의 전체 정보를 담은 UserResponse 객체를 JSON 형태로 클라이언트에게 최종 응답합니다.
        return loginService.authenticate(data.get("userId"), data.get("password"));
    }
}