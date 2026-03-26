import Foundation

//💡 1. 백엔드의 JSON 응답 구조를 받을 Swift 모델(Codable)
struct APIResponse<T: Codable>: Codable {
    let status: Int?
    let message: String?
    let data: PageData<T>?
}

struct PageData<T: Codable>: Codable {
    let content: [T]
}

// 메인 리스트에서 사용하는 실제 데이터 구조체
struct TradePostItem: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Int           // 일반거래: 판매가 / 경매: 시작가
    let category: String
    let status: String       // "SALE", "RESERVED", "SOLD" 등
    let imageUrl: String?
    let sellerNickname: String
    let viewCount: Int
    let wishCount: Int
    let postTime: String
    let endTime: String? //경매 타이머 위해 필요해서 추가
}

// MARK: - 거래 및 상태 관련 정의
enum SaleType {
    case normal    // 일반 거래 (당근마켓식)
    case auction   // 경매
}

enum TradeStatus: String, Codable {
    case SALE      // 판매중 (일반거래는 뱃지표시없이,경매에선 사용안함)
    case RESERVED  // 일반거래는 예약중, 경매는 진행중으로 뱃지표시
    case SOLD      // 거래완료
}

// MARK: - 추가 정보 (경매 및 상세 전용)
struct Item: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let price: Int
    let likeCount: Int
    let status: String
    let imageName: String
    let seller: SellerInfo
    let postTime: String
    let category: Category
    let saleType: SaleType
    let auctionEndTime: String?
    let currentBidPrice: Int?
    let bidCount: Int?
}

struct SellerInfo {
    let name: String
    let profileImageName: String
}

extension Int {
    var wonFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: self)) ?? "\(self)") + "원"
    }
}

enum Category: String, CaseIterable {
    case major      = "전공서적"
    case electronic = "전자기기"
    case living     = "생활용품"
    case furniture  = "자취/가구"
    case fashion    = "의류/잡화"
    case food       = "식품/간식"
    case ticket     = "티켓/양도"
    case assignment = "과제/자료"
    case etc        = "기타"
}

extension TradePostItem {
    func toItem() -> Item {
        return Item(
            id: UUID(),
            title: self.title,
            description: "",
            price: self.price,
            likeCount: self.wishCount,
            status: self.status,
            imageName: self.imageUrl ?? "",
            seller: SellerInfo(
                name: self.sellerNickname,
                profileImageName: ""
            ),
            postTime: self.postTime,
            category: Category(rawValue: self.category) ?? .etc,
            saleType: self.endTime != nil ? .auction : .normal,
            auctionEndTime: self.endTime,
            currentBidPrice: nil,
            bidCount: nil
        )
    }
}
