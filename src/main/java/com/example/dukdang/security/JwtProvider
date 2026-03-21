package com.example.dukdang.security; // 패키지 경로는 프로젝트에 맞게 수정

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtProvider {
    // 토큰 암호화에 사용할 비밀키 (실제로는 환경변수 등에 숨겨야 함)
    private final Key key = Keys.secretKeyFor(SignatureAlgorithm.HS256);
    // 토큰 유효 시간 (예: 1시간)
    private final long tokenExpiration = 3600000L;

    // 토큰 생성 메서드
    public String createToken(String email) {
        Date now = new Date();
        return Jwts.builder()
                .setSubject(email) // 토큰 주인 (이메일)
                .setIssuedAt(now)  // 발행 시간
                .setExpiration(new Date(now.getTime() + tokenExpiration)) // 만료 시간
                .signWith(key)     // 암호화 알고리즘과 키
                .compact();
    }
}
