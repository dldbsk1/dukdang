package com.example.dukdang.service;

import com.example.dukdang.dto.TradePostListResponseDto;
import com.example.dukdang.dto.TradePostRequestDto;
import com.example.dukdang.dto.TradePostResponseDto;
import com.example.dukdang.entity.*;
import com.example.dukdang.exception.CustomException;
import com.example.dukdang.exception.ErrorCode;
import com.example.dukdang.repository.PostSearchRepository;
import com.example.dukdang.repository.WishListRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class TradePostService {

    private final PostSearchRepository postSearchRepository;
    private final WishListRepository wishListRepository;
    private final ImageService imageService;

    // ── 목록 조회 ──────────────────────────────────────────────────
    // readOnly = true: 조회 전용. 변경 감지(dirty checking)를 꺼서 성능 향상
    @Transactional(readOnly = true)
    public Page<TradePostListResponseDto> getList(Category category, String keyword,
                                                  int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<TradePost> posts = postSearchRepository.search(category, keyword, pageable);

        return posts.map(post -> {
            long wishCount = wishListRepository.countByTradePost(post);
            return TradePostListResponseDto.from(post, wishCount);
        });
    }

    // ── 단건 조회 ──────────────────────────────────────────────────
    // readOnly 아님: 조회수를 올려야 하기 때문
    public TradePostResponseDto getOne(Long postId, User currentUser) {
        TradePost post = findPostOrThrow(postId);
        post.addViewCount();   // 변경 감지로 자동 UPDATE

        long wishCount = wishListRepository.countByTradePost(post);
        boolean isWished = currentUser != null &&
                wishListRepository.existsByUserAndTradePost(currentUser, post);

        return TradePostResponseDto.from(post, wishCount, isWished);
    }

    // ── 게시글 작성 ────────────────────────────────────────────────
    // 💡 [수정] 2. 게시글 작성(create) 메서드를 아래 코드로 완전히 교체합니다!
    // ── 게시글 작성 ────────────────────────────────────────────────
    public TradePostResponseDto create(TradePostRequestDto dto, User seller) {
        // 💡 [수정] 1장이 아닌 여러 장을 저장하고 리스트로 받습니다!
        List<String> realImageUrls = imageService.saveImages(dto.getImageUrls());

        TradePost post = TradePost.create(
                seller, dto.getTitle(), dto.getDescription(),
                dto.getPrice(), dto.getCategory(),
                realImageUrls // 💡 리스트째로 DB에 저장
        );

        TradePost saved = postSearchRepository.save(post);
        return TradePostResponseDto.from(saved, 0, false);
    }

    // ── 게시글 수정 ────────────────────────────────────────────────
    public TradePostResponseDto update(Long postId, TradePostRequestDto dto, User currentUser) {
        TradePost post = findPostOrThrow(postId);
        checkOwnership(post, currentUser);

        // 💡 [핵심 수정] 기존 사진과 새 사진을 구분해서 처리하는 깐깐한 경비원 투입!
        java.util.List<String> finalImageUrls = new java.util.ArrayList<>();

        if (dto.getImageUrls() != null) {
            for (String url : dto.getImageUrls()) {
                if (url.startsWith("http")) {
                    // 1. 이미 서버에 저장된 기존 사진이면 건드리지 않고 그대로 유지!
                    finalImageUrls.add(url);
                } else if (url.startsWith("data:image")) {
                    // 2. 갤러리에서 새로 고른 Base64 사진이면 파일로 예쁘게 변환해서 추가!
                    finalImageUrls.addAll(imageService.saveImages(java.util.List.of(url)));
                }
            }
        }

        // 💡 변환이 끝난 안전한 사진 리스트(finalImageUrls)를 넣어서 업데이트!
        post.update(dto.getTitle(), dto.getDescription(),
                dto.getPrice(), dto.getCategory(), finalImageUrls);

        long wishCount = wishListRepository.countByTradePost(post);
        return TradePostResponseDto.from(post, wishCount, false);
    }

    // ── 상태 변경 ──────────────────────────────────────────────────
    public void changeStatus(Long postId, TradeStatus newStatus, User currentUser) {
        TradePost post = findPostOrThrow(postId);
        checkOwnership(post, currentUser);
        post.changeStatus(newStatus);
    }

    // ── 게시글 삭제 ────────────────────────────────────────────────
    public void delete(Long postId, User currentUser) {
        TradePost post = findPostOrThrow(postId);
        checkOwnership(post, currentUser);
        postSearchRepository.delete(post);
    }

    // ── 찜 토글 ────────────────────────────────────────────────────
    // 찜이 없으면 추가, 있으면 취소 → 프론트에서 상태 관리 단순해짐
    public boolean toggleWish(Long postId, User currentUser) {
        TradePost post = findPostOrThrow(postId);

        if (wishListRepository.existsByUserAndTradePost(currentUser, post)) {
            WishList wish = wishListRepository
                    .findByUserAndTradePost(currentUser, post)
                    .orElseThrow();
            wishListRepository.delete(wish);
            return false;   // 찜 취소
        } else {
            wishListRepository.save(WishList.create(currentUser, post));
            return true;    // 찜 추가
        }
    }

    // ── 내 게시글 목록 ─────────────────────────────────────────────
    @Transactional(readOnly = true)
    public List<TradePostListResponseDto> getMyPosts(User currentUser) {
        return postSearchRepository.findBySellerOrderByPostTimeDesc(currentUser)
                .stream()
                .map(post -> TradePostListResponseDto.from(post,
                        wishListRepository.countByTradePost(post)))
                .toList();
    }

    // ── 내 찜 목록 ─────────────────────────────────────────────────
    @Transactional(readOnly = true)
    public List<TradePostListResponseDto> getMyWishList(User currentUser) {
        return wishListRepository.findByUserOrderByPostTimeDesc(currentUser)
                .stream()
                .map(wish -> TradePostListResponseDto.from(wish.getTradePost(),
                        wishListRepository.countByTradePost(wish.getTradePost())))
                .toList();
    }

    // ── 공통 헬퍼 메서드 ───────────────────────────────────────────
    // 반복되는 "조회 + 없으면 예외" 패턴 추출 → 중복 제거
    private TradePost findPostOrThrow(Long postId) {
        return postSearchRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.POST_NOT_FOUND));
    }

    // 작성자 본인인지 확인 → Service에서 권한 체크, Controller는 신경 안 써도 됨
    private void checkOwnership(TradePost post, User currentUser) {
        if (!post.getSeller().getId().equals(currentUser.getId())) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }
    }
}