package com.example.dukdang.service;

import com.example.dukdang.dto.LoginRequestDto;
import com.example.dukdang.dto.LoginResponseDto;
import com.example.dukdang.dto.SignupRequestDto;
import com.example.dukdang.entity.User;
import com.example.dukdang.exception.CustomException;
import com.example.dukdang.exception.ErrorCode;
import com.example.dukdang.jwt.JwtUtil;
import com.example.dukdang.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class AuthService {

    // 💡 static 제거!
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    public void signup(SignupRequestDto dto) {
        if (userRepository.existsByEmail(dto.getEmail())) {
            throw new CustomException(ErrorCode.DUPLICATE_EMAIL);
        }
        String encodedPassword = passwordEncoder.encode(dto.getPassword());
        userRepository.save(User.create(dto.getEmail(), encodedPassword, dto.getNickname()));
    }

    // 반환 타입을 String에서 LoginResponseDto로 변경합니다.
    public LoginResponseDto login(LoginRequestDto dto) {
        User user = userRepository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
        }

        // 토큰 생성
        String token = jwtUtil.generateToken(user.getEmail(), user.getRole());

        // 💡 토큰과 DB에 저장된 유저의 고유 ID를 함께 반환합니다!
        return new LoginResponseDto(token, user.getId());
    }


    public boolean checkEmail(String email) {
        // 이메일이 DB에 존재하면(true) 사용 불가이므로, 반대인 false를 리턴.
        // 존재하지 않으면(false) 사용 가능하므로 true를 리턴.
        return !userRepository.existsByEmail(email);
    }
}