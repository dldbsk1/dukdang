package com.example.dukdang.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

@Component
public class JwtProvider {

    // 1. application.properties에서 값을 가져옵니다.
    @Value("${jwt.secret}")
    private String secretKey;

    @Value("${jwt.expiration}")
    private long tokenExpiration;

    private Key key;

    // 2. 객체 생성 후 비밀키를 초기화합니다.
    @PostConstruct
    protected void init() {
        this.key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }

    // 토큰 생성 메서드
    public String createToken(String email) {
        Date now = new Date();
        return Jwts.builder()
                .setSubject(email)
                .setIssuedAt(now)
                .setExpiration(new Date(now.getTime() + tokenExpiration))
                .signWith(key, SignatureAlgorithm.HS256) // 알고리즘 명시
                .compact();
    }
}
