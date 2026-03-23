package com.example.dukdang;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing   // @PostTime 동작에 필요
public class DukdangApplication {
    public static void main(String[] args) {
        SpringApplication.run(DukdangApplication.class, args);
    }
}