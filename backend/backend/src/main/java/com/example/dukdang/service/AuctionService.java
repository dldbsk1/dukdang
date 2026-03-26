package com.example.dukdang.service;

import com.example.dukdang.dto.*;
import com.example.dukdang.entity.*;
import com.example.dukdang.exception.CustomException;
import com.example.dukdang.exception.ErrorCode;
import com.example.dukdang.repository.AuctionBidRepository;
import com.example.dukdang.repository.AuctionPostRepository;
import com.example.dukdang.repository.ChatRoomRepository; // 💡 채팅방 리포지토리
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class AuctionService {

    private final AuctionPostRepository auctionPostRepository;
    private final AuctionBidRepository auctionBidRepository;
    private final ImageService imageService;
    private final ChatRoomRepository chatRoomRepository; // 💡 채팅방 리포지토리 의존성 주입

    // ── 경매 등록 ──────────────────────────────────────────────
    public AuctionPostResponseDto create(AuctionPostRequestDto dto, User seller) {
        LocalDateTime startTime = dto.getStartTime() != null
                ? dto.getStartTime()
                : LocalDateTime.now();  // 즉시 시작

        // 프론트가 보내준 1시 12분 같은 정확한 시간을 그대로 씁니다!
        LocalDateTime endTime = dto.getEndTime() != null
                ? dto.getEndTime()
                : startTime.plusDays(1); // 혹시 안 오면 1일 뒤로

        List<String> realImageUrls = imageService.saveImages(dto.getImageUrls());

        AuctionPost post = AuctionPost.create(
                seller,
                dto.getTitle(),
                dto.getDescription(),
                dto.getMinPrice(),
                dto.getCategory(),
                realImageUrls,
                startTime,
                endTime // 정확한 시간 투입!
        );
        AuctionPost saved = auctionPostRepository.save(post);
        return AuctionPostResponseDto.from(saved, 0, true, false);
    }

    // ── 목록 조회 ──────────────────────────────────────────────
    @Transactional(readOnly = true)
    public Page<AuctionPostListResponseDto> getList(Category category,
                                                    String keyword,
                                                    int page, int size) {
        Page<AuctionPost> posts = auctionPostRepository.search(
                category, keyword, PageRequest.of(page, size));

        return posts.map(post -> {
            long bidCount = auctionBidRepository.countByAuctionPost(post);
            return AuctionPostListResponseDto.from(post, bidCount);
        });
    }

    // ── 단건 조회 ──────────────────────────────────────────────
    @Transactional(readOnly = true)
    public AuctionPostResponseDto getOne(Long postId, User currentUser) {
        AuctionPost post = findPostOrThrow(postId);

        boolean isSeller = post.getSeller().getId().equals(currentUser.getId());
        long bidCount = auctionBidRepository.countByAuctionPost(post);
        boolean isMyHighestBid = !isSeller &&
                auctionBidRepository.isCurrentHighestBidder(post, currentUser);

        return AuctionPostResponseDto.from(post, bidCount, isSeller, isMyHighestBid);
    }

    // ── 입찰 ──────────────────────────────────────────────────
    public AuctionBidResponseDto bid(AuctionBidRequestDto dto, User bidder) {
        AuctionPost post = findPostOrThrow(dto.getAuctionPostId());

        // 본인 경매 입찰 방지
        if (post.getSeller().getId().equals(bidder.getId())) {
            throw new CustomException(ErrorCode.CANNOT_BID_OWN_AUCTION);
        }

        // 진행중인 경매만 입찰 가능
        if (post.getStatus() != AuctionStatus.ACTIVE) {
            throw new CustomException(ErrorCode.AUCTION_NOT_ACTIVE);
        }

        // 첫 입찰이면 minPrice 이상, 이후엔 현재 최고가보다 높아야 함
        int threshold = post.getCurrentHighestPrice() != null
                ? post.getCurrentHighestPrice()
                : post.getMinPrice() - 1;

        if (dto.getBidPrice() <= threshold) {
            throw new CustomException(ErrorCode.BID_PRICE_TOO_LOW);
        }

        // 입찰 저장 + 경매글 최고가 갱신
        AuctionBid bid = AuctionBid.create(post, bidder, dto.getBidPrice());
        AuctionBid saved = auctionBidRepository.save(bid);
        post.updateHighestPrice(dto.getBidPrice());  // dirty checking으로 자동 UPDATE

        return AuctionBidResponseDto.from(saved, true);
    }

    // ── 내 입찰 내역 조회 ──────────────────────────────────────
    @Transactional(readOnly = true)
    public List<AuctionBidResponseDto> getMyBids(Long postId, User currentUser) {
        AuctionPost post = findPostOrThrow(postId);
        boolean isMyHighestBid = auctionBidRepository
                .isCurrentHighestBidder(post, currentUser);

        return auctionBidRepository
                .findByBidderAndAuctionPostOrderByPostTimeDesc(currentUser, post)
                .stream()
                .map(bid -> AuctionBidResponseDto.from(bid,
                        isMyHighestBid && bid.getBidPrice() == post.getCurrentHighestPrice()))
                .toList();
    }

    // ── 내가 등록한 경매 목록 ──────────────────────────────────
    @Transactional(readOnly = true)
    public List<AuctionPostListResponseDto> getMyAuctions(User currentUser) {
        return auctionPostRepository.findBySellerOrderByPostTimeDesc(currentUser)
                .stream()
                .map(post -> AuctionPostListResponseDto.from(post,
                        auctionBidRepository.countByAuctionPost(post)))
                .toList();
    }

    // ── 거래 완료 처리 (낙찰자가 완료 버튼 누를 때) ────────────
    public void complete(Long postId, User currentUser) {
        AuctionPost post = findPostOrThrow(postId);

        if (post.getStatus() != AuctionStatus.ENDED) {
            throw new CustomException(ErrorCode.AUCTION_NOT_ENDED);
        }
        boolean isWinner = post.getWinner() != null &&
                post.getWinner().getId().equals(currentUser.getId());
        boolean isSeller = post.getSeller().getId().equals(currentUser.getId());

        if (!isWinner && !isSeller) {
            throw new CustomException(ErrorCode.FORBIDDEN);
        }
        post.complete();
    }

    // ── 스케줄러에서 호출 ─────────────────────────────────────
    // WAITING → ACTIVE 전환
    public void activateScheduled() {
        auctionPostRepository
                .findByStatusAndStartTimeBefore(AuctionStatus.WAITING, LocalDateTime.now())
                .forEach(AuctionPost::activate);
    }

    // 💡 ACTIVE → ENDED 전환 + 낙찰자 결정 및 채팅방 생성!
    public void endScheduled() {
        auctionPostRepository
                .findByStatusAndEndTimeBefore(AuctionStatus.ACTIVE, LocalDateTime.now())
                .forEach(post -> {
                    // 최고 입찰자를 낙찰자로 결정
                    User winner = auctionBidRepository
                            .findTop1ByAuctionPostOrderByBidPriceDesc(post)
                            .map(AuctionBid::getBidder)
                            .orElse(null);  // 입찰자 없으면 null → CANCELLED
                    post.end(winner);

                    // 💡 드디어 마법이 이루어지는 순간! 낙찰자가 있으면 채팅방을 짠! 하고 만듭니다.
                    if (winner != null) {
                        ChatRoom auctionChatRoom = ChatRoom.createForAuction(post, winner);
                        chatRoomRepository.save(auctionChatRoom); // DB에 쾅! 저장!

                        System.out.println("🎉 [경매 종료] 낙찰 성공! 판매자(" + post.getSeller().getNickname() +
                                ") - 구매자(" + winner.getNickname() + ") 채팅방 생성 완료!");
                    } else {
                        System.out.println("😢 [경매 종료] 유찰되었습니다. (참여자 없음) : " + post.getTitle());
                    }
                });
    }

    private AuctionPost findPostOrThrow(Long postId) {
        return auctionPostRepository.findById(postId)
                .orElseThrow(() -> new CustomException(ErrorCode.AUCTION_NOT_FOUND));
    }
}