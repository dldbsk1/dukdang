package com.example.dukdang.service;

import com.example.dukdang.dto.LoginRequestDto;
import com.example.dukdang.dto.SignupRequestDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.repository.UserRepository;
import com.example.dukdang.security.JwtProvider; // JwtProvider 패키지 경로 확인 필요
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final JwtProvider jwtProvider; // 1. JwtProvider 의존성 주입 추가

    // 회원가입
    @Transactional
    public void signup(SignupRequestDto request) {
        // 1. 이메일 중복 확인
        userRepository.findByEmail(request.getEmail())
                .ifPresent(u -> { throw new IllegalArgumentException("이미 존재하는 이메일입니다."); });

        // 2. User 엔티티 생성 및 저장
        User user = User.create(
                request.getEmail(),
                request.getPassword(),
                request.getNickname()
        );
        userRepository.save(user);
    }

    // 로그인: 반환 타입을 String(토큰)으로 변경
    @Transactional(readOnly = true)
    public String login(LoginRequestDto request) {
        // 1. 이메일 확인
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new IllegalArgumentException("등록되지 않은 사용자입니다."));

        // 2. 비밀번호 일치 확인
        if (!user.getPassword().equals(request.getPassword())) {
            throw new IllegalArgumentException("비밀번호가 일치하지 않습니다.");
        }

        // 3. 로그인 성공 시 JWT 토큰 생성 및 반환
        return jwtProvider.createToken(user.getEmail());
    }
}