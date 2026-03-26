package com.example.dukdang.config;

import com.google.genai.Client;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AIConfig {

    @Value("${gemini.api-key}")
    private String apiKey;

    // ChatClient.Builder 패턴과 동일한 역할
    // — Bean으로 등록해두면 Service에서 그냥 주입받아 쓰면 됨
    @Bean
    public Client geminiClient() {
        return new Client.Builder()
                .apiKey(apiKey)
                .build();
    }
}