package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

// entity/User.java
@Entity
@Table(name = "users")
@Getter                    // ← 이게 있어야 getId(), getNickname() 등이 생김
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;           // ← getId() 생김

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, length = 20)
    private String nickname;   // ← getNickname() 생김

    private String profileImg;

    @Enumerated(EnumType.STRING)
    private Role role;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;

    public static User create(String email, String password, String nickname) {
        User user = new User();
        user.email = email;
        user.password = password;
        user.nickname = nickname;
        user.role = Role.USER;
        return user;
    }
}