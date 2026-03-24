package com.example.dukdang.repository;

import com.example.dukdang.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);

    // 추가: 닉네임 중복 검사
    boolean existsByNickname(String nickname);
}
