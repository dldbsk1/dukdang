package com.example.dukdang.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

@Service
public class ImageService {

    @Value("${file.upload-dir}")
    private String uploadDir;

    @Value("${file.upload-url}")
    private String uploadUrl;

    // 💡 [추가된 부분] 여러 장의 Base64 사진을 받아서 모두 저장하고 URL 리스트로 반환
    public List<String> saveImages(List<String> base64Images) {
        if (base64Images == null || base64Images.isEmpty()) return new ArrayList<>();

        List<String> savedUrls = new ArrayList<>();
        for (String base64 : base64Images) {
            String url = saveImage(base64); // 기존의 1장 저장하는 함수 재사용
            if (!url.isEmpty()) savedUrls.add(url);
        }
        return savedUrls;
    }

    // 💡 [기존 부분 복구!] 1장의 사진을 저장하는 원본 함수
    public String saveImage(String base64Image) {
        if (!StringUtils.hasText(base64Image)) {
            return ""; // 사진이 없으면 빈 문자열 반환
        }

        try {
            String base64Data = base64Image.substring(base64Image.indexOf(",") + 1);
            byte[] imageBytes = Base64.getDecoder().decode(base64Data);

            String fileName = UUID.randomUUID().toString() + ".png";

            // 폴더가 없으면 자동 생성
            File directory = new File(uploadDir);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            File uploadFile = new File(uploadDir, fileName);

            try (FileOutputStream fos = new FileOutputStream(uploadFile)) {
                fos.write(imageBytes);
            }

            return uploadUrl + "/" + fileName;

        } catch (IOException | IllegalArgumentException e) {
            return ""; // 디코딩 실패 시 빈 문자열
        }
    }
}