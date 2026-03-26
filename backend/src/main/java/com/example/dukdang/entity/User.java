package com.example.dukdang.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false, length = 20)
    private String nickname;

    private String profileImg;

    @Enumerated(EnumType.STRING)
    private Role role;

    // 💡 [추가] 마이페이지용 동네와 매너온도 필드 추가
    private String location;
    private Double temperature;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime postTime;

    public static User create(String email, String password, String nickname) {
        User user = new User();
        user.email = email;
        user.password = password;
        user.nickname = nickname;
        user.role = Role.USER;
        // 💡 가입 시 기본값 설정
        user.location = "동네 미설정";
        user.temperature = 36.5;
        return user;
    }

    // 💡 [추가] 프로필 수정용 메서드
    public void updateProfile(String nickname, String location, String profileImg) {
        this.nickname = nickname;
        this.location = location;
        this.profileImg = profileImg;
    }
}