package com.example.dukdang.controller;

import com.example.dukdang.service.PostListService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.*;

/**
 * [클래스 기술 정의] 게시글 목록 조회(Read) 및 검색 기능을 담당하는 REST API 컨트롤러입니다. [cite: 1]
 * [분리 목적] 게시글 생성, 수정 등 상태 변경 API와 조회 API를 분리하여 유지보수성을 높였습니다. [cite: 1]
 */
@RestController // 메서드의 반환값을 JSON 형식으로 변환하여 HTTP 응답 본문(Response Body)에 직접 작성합니다. [cite: 1]
@RequiredArgsConstructor // 초기화되지 않은 final 필드에 대해 생성자를 자동 생성하여 스프링의 의존성 주입(DI)을 처리합니다. [cite: 1]
@RequestMapping("/api/trade") // 이 컨트롤러 내 모든 메서드가 공유할 공통 URL 경로(/api/trade)를 정의합니다. [cite: 1]
public class PostListController {

    // 비즈니스 로직(Firestore 쿼리 및 데이터 가공)을 수행하는 서비스 계층의 객체입니다. [cite: 1]
    private final PostListService postListService;

    /**
     * [메서드 기술 정의] 전체 게시글 목록 또는 조건부(카테고리/키워드) 게시글 목록을 조회하여 반환합니다. [cite: 1]
     * [동작 주소] GET http://localhost:8080/api/trade/posts [cite: 1]
     */
    @GetMapping("/posts") // HTTP GET 메서드 요청을 해당 경로에 매핑하여 리소스 조회 로직을 실행합니다. [cite: 1]
    public List<Map<String, Object>> getPosts(

            /**
             * @RequestParam: URL 쿼리 파라미터(?key=value)에서 데이터를 추출합니다. [cite: 1]
             * required = false: 해당 파라미터가 요청에 포함되지 않아도 400 에러를 발생시키지 않고 null을 허용합니다. [cite: 1]
             */
            @RequestParam(required = false) String category, // 특정 카테고리 필터링을 위한 식별자 값입니다. [cite: 1]
            @RequestParam(required = false) String keyword) throws Exception { // 검색창에 입력한 제목 기반 검색어입니다. [cite: 1]

        /**
         * [제어 흐름]
         * 1. 클라이언트의 요청 파라미터(category, keyword)를 수신합니다. [cite: 1]
         * 2. 수신된 데이터를 PostListService로 전달하여 DB 조회를 위임합니다. [cite: 1]
         * 3. 서비스로부터 반환받은 게시글 리스트를 JSON 배열 형태로 클라이언트에 응답합니다. [cite: 1]
         */
        return postListService.getPosts(category, keyword);
    }
}