package com.example.dukdang.repository;

import com.example.dukdang.entity.AuctionBid;
import com.example.dukdang.entity.AuctionPost;
import com.example.dukdang.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AuctionBidRepository extends JpaRepository<AuctionBid, Long> {

    // 특정 경매의 최고 입찰 내역 (낙찰자 결정에 사용)
    Optional<AuctionBid> findTop1ByAuctionPostOrderByBidPriceDesc(AuctionPost post);

    // 특정 경매의 입찰 횟수 (판매자에게 보여줄 정보)
    long countByAuctionPost(AuctionPost post);

    // 내 입찰 내역 (구매자용)
    List<AuctionBid> findByBidderAndAuctionPostOrderByPostTimeDesc(
            User bidder, AuctionPost post);

    // 내가 이 경매의 현재 최고 입찰자인지 확인
    @Query("SELECT COUNT(b) > 0 FROM AuctionBid b WHERE b.auctionPost = :post " +
            "AND b.bidder = :bidder " +
            "AND b.bidPrice = (SELECT MAX(b2.bidPrice) FROM AuctionBid b2 " +
            "                  WHERE b2.auctionPost = :post)")
    boolean isCurrentHighestBidder(@Param("post") AuctionPost post,
                                   @Param("bidder") User bidder);
}