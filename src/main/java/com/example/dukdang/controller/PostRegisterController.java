package com.example.dukdang.controller;

import com.example.dukdang.dto.PostRequest;
import com.example.dukdang.service.PostRegisterService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

/**
 * [클래스 목적] 새로운 판매 게시글을 생성(등록)하는 API 요청만을 전담하여 처리하는 컨트롤러
 */
@RestController // 메서드의 반환값을 뷰(HTML)가 아닌 데이터(JSON, 문자열 등)로 클라이언트에게 직접 응답하도록 설정
@RequiredArgsConstructor // final이 붙은 필드(postRegisterService)를 초기화하는 생성자를 자동 생성하여 스프링 빈(Bean) 의존성을 주입받음
@RequestMapping("/api/trade") // 이 클래스의 모든 API 엔드포인트가 공통으로 가질 최상위 URL 경로를 지정
public class PostRegisterController {

    // DB 저장 등 실제 비즈니스 로직을 수행할 서비스 계층의 객체
    private final PostRegisterService postRegisterService;

    /**
     * [메서드 목적] 클라이언트가 보낸 게시글 생성 요청을 받아 서비스 계층으로 전달
     */
    @PostMapping("/post") // HTTP POST 메서드로 들어오는 "/api/trade/post" 요청을 이 메서드에 매핑 (보통 리소스 생성에 사용)
    public String createPost(
            // @RequestBody: HTTP 요청의 본문(Body)에 담긴 JSON 형식의 데이터를 PostRequest 객체(DTO)로 변환하여 바인딩
            @RequestBody PostRequest request) throws Exception {

        // 컨트롤러에서 처리된 객체를 서비스 계층으로 넘겨 DB 저장 로직을 실행하고, 반환된 결과(생성된 게시글의 문서 ID 등)를 클라이언트에게 응답
        return postRegisterService.registerPost(request);
    }
}