enum SaleType {
    case normal    // 일반 거래 (당근마켓식)
    case auction   // 경매
}

public enum TradeStatus {
    let SALE, // 판매중
    let RESERVED, // 예약중
    let SOLD // 거래완료
}

public enum Category {
    CLOTHES,
    BOOK,
    ELECTRONICS
}
struct Item: Identifiable {

    let id: UUID
    let title: String
    let description: String
    let price: Int         // 일반거래: 판매가 / 경매: 시작가
    let likeCount: Int
    let status: String
    let imageName: String
    let seller: SellerInfo
    let postTime: String
    let saleType: SaleType  // ✅ 거래 방식 구분
    
    // 경매 전용 (일반거래면 nil)
    let auctionEndTime: String?   // 경매 마감 시간
    let currentBidPrice: Int?     // 현재 최고 입찰가
    let bidCount: Int?
}

struct SellerInfo {
    let name: String
    let profileImageName: String

}
