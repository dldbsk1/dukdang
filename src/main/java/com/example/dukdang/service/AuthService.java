package com.example.dukdang.service;

import com.example.dukdang.dto.LoginRequestDto;
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

    public String login(LoginRequestDto dto) {
        User user = userRepository.findByEmail(dto.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_PASSWORD);
        }

        return jwtUtil.generateToken(user.getEmail(), user.getRole());
    }
}