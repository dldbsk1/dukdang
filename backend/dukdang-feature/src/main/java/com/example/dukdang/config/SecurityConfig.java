package com.example.dukdang.config;

import com.example.dukdang.jwt.JwtFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtFilter jwtFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // 💡 [여기에 추가!] 누구나 사진 주소에 접속해서 볼 수 있도록 허용합니다.
                        .requestMatchers("/uploads/**").permitAll()
                        // 💡 [여기에 추가!] 웹소켓 엔드포인트는 시큐리티(HTTP) 필터에서 통과시켜줍니다.
                        .requestMatchers("/ws-chat/**").permitAll()
                        // 게시글 목록/단건 조회는 비로그인도 허용
                        .requestMatchers(HttpMethod.GET, "/trade-posts", "/trade-posts/*").permitAll()
                        // 인증/Swagger는 누구나
                        .requestMatchers("/auth/**", "/swagger-ui/**", "/v3/api-docs/**").permitAll()
                        // /ai 요청 로그인 시 허용
                        .requestMatchers("/ai/**").authenticated()
                        // 나머지는 로그인 필요
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}