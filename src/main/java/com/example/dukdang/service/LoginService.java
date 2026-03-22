package com.example.dukdang.service;

import com.example.dukdang.dto.UserResponse;
import com.google.cloud.firestore.Firestore;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * [클래스 목적] Firestore DB와 연동하여 사용자의 회원가입 중복 체크, 데이터 저장 및 로그인 인증(아이디/비밀번호 검증) 비즈니스 로직을 전담하는 서비스 계층입니다.
 */
@Service // 스프링 컨테이너에 서비스 빈(Bean)으로 등록하여 핵심 비즈니스 로직을 수행하는 계층임을 명시합니다.
@RequiredArgsConstructor // final로 선언된 필드(db)에 대한 생성자를 자동 생성하여, 의존성을 안전하게 주입받습니다.
public class LoginService {

    // DB 연동을 위한 Google Cloud Firestore 클라이언트 객체입니다.
    private final Firestore db;

    /**
     * [메서드 목적] 클라이언트로부터 전달받은 회원가입 정보를 Firestore DB에 저장합니다. 저장 전 아이디 중복 여부를 검증합니다.
     */
    public String register(UserResponse request) throws Exception {
        // 1. 'users' 컬렉션에서 클라이언트가 요청한 userId와 동일한 ID를 가진 문서(Document)를 단건 조회합니다.
        var existingUser = db.collection("users").document(request.getUserId()).get().get();

        // 2. 해당 문서가 이미 존재한다면 중복된 아이디이므로 "already_exists" 문자열을 반환하여 가입을 차단합니다.
        if (existingUser.exists()) {
            return "already_exists";
        }

        // 3. 문서가 존재하지 않는다면(새로운 유저), 요청받은 DTO 객체(request)의 데이터를 해당 문서 위치에 새롭게 저장(set)합니다.
        db.collection("users").document(request.getUserId()).set(request).get();

        // 정상적으로 저장이 완료되었음을 알리는 문자열을 반환합니다.
        return "success";
    }

    /**
     * [메서드 목적] 사용자가 입력한 아이디와 비밀번호를 DB 데이터와 대조하여 로그인 인증을 수행합니다.
     */
    public UserResponse authenticate(String id, String pw) throws Exception {
        // 1. 'users' 컬렉션에서 'userId' 필드 값이 파라미터로 받은 id와 일치하는 문서를 찾는 조건부 쿼리를 실행합니다.
        var result = db.collection("users")
                .whereEqualTo("userId", id)
                .get().get();

        // 2. 쿼리 결과(QuerySnapshot)가 비어있지 않은지(해당 아이디의 회원이 존재하는지) 확인합니다.
        if (!result.isEmpty()) {
            // 3. 결과 목록 중 첫 번째 문서 데이터를 가져옵니다. (아이디는 고유하므로 첫 번째 값이 유일한 값입니다)
            var doc = result.getDocuments().get(0);

            // 4. DB에 저장된 "password" 문자열 데이터와 파라미터로 받은 pw가 정확히 일치하는지 검증합니다.
            if (pw.equals(doc.getString("password"))) {
                // 5. 비밀번호가 일치하면, Firestore의 문서 데이터를 UserResponse 클래스 타입의 객체로 자동 변환(toObject)하여 반환합니다.
                return doc.toObject(UserResponse.class);
            }
        }
        // 아이디가 존재하지 않거나 비밀번호가 틀린 경우 인증 실패를 의미하는 null을 반환합니다.
        return null;
    }
}