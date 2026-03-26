import SwiftUI

// MARK: - ViewModel (API 연결 대비)

class WishlistViewModel: ObservableObject {
    @Published var items: [TradePostItem] = []
    @Published var isLoading: Bool = false

    // 나중에 API 연결 시 이 함수만 교체하면 됨
    func fetchWishlist() {
        isLoading = true

        // TODO: API 연결 시 아래 더미 데이터 제거 후 네트워크 코드로 교체
        // 예시:
        // let url = URL(string: "https://api.example.com/wishlist")!
        // URLSession.shared.dataTask(with: url) { data, _, _ in
        //     let decoded = try? JSONDecoder().decode(APIResponse<TradePostItem>.self, from: data!)
        //     DispatchQueue.main.async {
        //         self.items = decoded?.data?.content ?? []
        //         self.isLoading = false
        //     }
        // }.resume()

        self.items = [
            TradePostItem(id: 1, title: "후드 집업", price: 15000, category: Category.fashion.rawValue, status: "SALE", imageUrl: nil, sellerNickname: "옷장정리중", viewCount: 10, wishCount: 23, postTime: "5분 전", endTime: nil),
            TradePostItem(id: 2, title: "스탠딩 책상", price: 45000, category: Category.furniture.rawValue, status: "RESERVED", imageUrl: nil, sellerNickname: "자취생", viewCount: 8, wishCount: 12, postTime: "1시간 전", endTime: nil),
            TradePostItem(id: 3, title: "알고리즘 전공서적", price: 12000, category: Category.major.rawValue, status: "SALE", imageUrl: nil, sellerNickname: "졸업생", viewCount: 5, wishCount: 7, postTime: "3시간 전", endTime: nil),
            TradePostItem(id: 4, title: "무선 이어폰", price: 30000, category: Category.electronic.rawValue, status: "SALE", imageUrl: nil, sellerNickname: "전자왕", viewCount: 20, wishCount: 31, postTime: "어제", endTime: nil),
            TradePostItem(id: 5, title: "콘서트 티켓 양도", price: 88000, category: Category.ticket.rawValue, status: "SALE", imageUrl: nil, sellerNickname: "티켓판매", viewCount: 15, wishCount: 9, postTime: "2일 전", endTime: nil),
            TradePostItem(id: 6, title: "자취용 전기밥솥", price: 20000, category: Category.living.rawValue, status: "SOLD", imageUrl: nil, sellerNickname: "이사가요", viewCount: 11, wishCount: 5, postTime: "3일 전", endTime: nil),
        ]

        isLoading = false
    }
}

// MARK: - 메인 뷰

struct WishlistView: View {

    @StateObject private var viewModel = WishlistViewModel()
    @State private var selectedCategory: String = "전체"
    @State private var goToChat = false

    // 카테고리 목록: "전체" + Category enum
    let categories: [String] = ["전체"] + Category.allCases.map { $0.rawValue }

    var filteredItems: [TradePostItem] {
        if selectedCategory == "전체" {
            return viewModel.items
        } else {
            return viewModel.items.filter { $0.category == selectedCategory }
        }
    }

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // 상품 개수 + 카테고리 필터
                VStack(alignment: .leading, spacing: 0) {
                    Text("상품 \(filteredItems.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                    Divider()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { category in
                                CategoryChip(
                                    title: category,
                                    isSelected: selectedCategory == category
                                )
                                .onTapGesture {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }

                    Divider()
                }

                // 로딩 or 상품 리스트
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("불러오는 중...")
                    Spacer()
                } else if filteredItems.isEmpty {
                    Spacer()
                    Text("찜한 상품이 없어요 🥲")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredItems) { item in
                                WishlistCell(item: item)
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("좋아요")
                        .font(.system(size: 28, weight: .bold))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20))
                }
            }
            
            .onAppear {
                viewModel.fetchWishlist()
            }
        }
    }
}

// MARK: - 카테고리 칩

struct CategoryChip: View {
    let title: String
    var isSelected: Bool = false

    var body: some View {
        Text(title)
            .font(.system(size: 15))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Color(red: 0.75, green: 0.9, blue: 1.0) : Color.gray.opacity(0.15))
            )
            .foregroundColor(.black)
    }
}

// MARK: - 상품 셀

struct WishlistCell: View {
    let item: TradePostItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {

            // 상품 이미지 (URL or SF Symbol 폴백)
            if let urlStr = item.imageUrl, urlStr.hasPrefix("http"),
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(10)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.4))
                            .font(.largeTitle)
                    )
            }

            // 판매자 닉네임
            Text(item.sellerNickname)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.horizontal, 3)

            VStack(alignment: .leading, spacing: 5) {
                // 상품명 + 상태 뱃지
                HStack(spacing: 4) {
                    if let status = TradeStatus(rawValue: item.status), status != .SALE {
                        Text(status == .RESERVED ? "예약중" : "거래완료")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(status == .RESERVED ? Color.orange : Color.gray)
                            .cornerRadius(4)
                    }
                    Text(item.title)
                        .font(.subheadline)
                        .lineLimit(1)
                }

                // 가격
                Text(item.price.wonFormatted)
                    .font(.footnote)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 131/255, green: 26/255, blue: 44/255))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 5)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - 프리뷰

#Preview {
    WishlistView()
}
