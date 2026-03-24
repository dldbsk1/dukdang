package com.example.dukdang.service;

import com.example.dukdang.entity.TradePost;
import com.example.dukdang.entity.User;
import com.example.dukdang.entity.WishList;
import com.example.dukdang.repository.PostSearchRepository;
import com.example.dukdang.repository.WishListRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class WishListService {
    private final WishListRepository wishListRepository; //
    private final PostSearchRepository postSearchRepository; //

    @Transactional
    public boolean toggleWishList(Long postId, User user) {
        System.out.println("👉 [1단계] 서비스 진입. postId: " + postId); // 로그 추가

        TradePost tradePost = postSearchRepository.findById(postId)
                .orElseThrow(() -> {
                    System.out.println("❌ [에러] 해당 ID의 게시글이 DB에 없음!");
                    return new IllegalArgumentException("게시글 없음");
                });

        System.out.println("👉 [2단계] 게시글 찾음: " + tradePost.getTitle());

        Optional<WishList> wishOptional = wishListRepository.findByUserAndTradePost(user, tradePost);

        if (wishOptional.isPresent()) {
            System.out.println("👉 [3단계] 이미 찜한 상태 -> 삭제 진행");
            wishListRepository.delete(wishOptional.get());
            return false;
        } else {
            System.out.println("👉 [3단계] 처음 찜하는 상태 -> 저장 진행");
            wishListRepository.save(WishList.create(user, tradePost));
            return true;
        }
    }

    @Transactional(readOnly = true)
    public boolean isLiked(Long postId, User user) {
        // 1. 게시글 존재 확인 (조회 쿼리 발생)
        TradePost tradePost = postSearchRepository.findById(postId)
                .orElseThrow(() -> new IllegalArgumentException("해당 게시글이 없습니다. ID: " + postId));

        // 2. Repository를 통해 존재 여부 반환
        return wishListRepository.existsByUserAndTradePost(user, tradePost);
    }


    // 이 메서드가 없어서 컴파일 에러가 났던 것입니다!
    @Transactional(readOnly = true)
    public List<WishList> getMyWishList(User user) {
        System.out.println("👉 [목록조회] 유저: " + user.getEmail());
        return wishListRepository.findByUserOrderByPostTimeDesc(user);
    }
}