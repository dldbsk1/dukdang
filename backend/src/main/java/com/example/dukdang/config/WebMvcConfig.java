package com.example.dukdang.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // iOS 앱이 "http://localhost:8080/uploads/images/사진.png" 로 접속하면
        // 백엔드 프로젝트 폴더 안에 있는 실제 "uploads/images" 폴더를 연결해 줍니다.
        registry.addResourceHandler("/uploads/images/**")
                .addResourceLocations("file:uploads/images/");
    }
}
