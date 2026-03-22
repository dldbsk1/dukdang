package com.example.dukdang;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @GetMapping("/test")
    public String test() {
        return "덕담 백엔드 서버가 정상적으로 실행 중입니다! (Java 21)";
    }
}
