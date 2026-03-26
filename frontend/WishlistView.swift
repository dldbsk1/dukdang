import SwiftUI
import Foundation

// MARK: - 1. API 응답 및 데이터 모델
struct WishListResponse: Codable, Identifiable {
    let id: Int
    let tradePost: WishTradePost // 실제 게시글 정보
}

struct WishTradePost: Codable {
    let id: Int
    let title: String
    let price: Int
    let imageName: String
    let category: String
    let sellerNickname: String
}

// MARK: - 2. 메인 뷰
struct WishlistView: View {
    @State private var wishItems: [WishListResponse] = [] // 💡 서버에서 가져온 진짜 데이터
    @State private var selectedCategory: String = "전체"
    @State private var goToChat = false
    
    let categories = ["전체", "의류", "신발", "가방", "뷰티"]
    
    // 💡 그리드 레이아웃 정의 (3열)
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // 💡 카테고리 필터링 로직
    var filteredItems: [WishListResponse] {
        if selectedCategory == "전체" {
            return wishItems
        } else {
            return wishItems.filter { $0.tradePost.category == selectedCategory }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단: 상품 개수 + 카테고리 필터
                VStack(alignment: .leading, spacing: 0) {
                    Text("상품 \(filteredItems.count)")
                        .font(.subheadline).fontWeight(.semibold)
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    
                    Divider()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { category in
                                CategoryChip(title: category, isSelected: selectedCategory == category)
                                    .onTapGesture { selectedCategory = category }
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 10)
                    }
                    Divider()
                }
                
                // 본문: 찜한 상품 그리드
                ScrollView {
                    if filteredItems.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "heart.slash").font(.largeTitle).foregroundColor(.gray)
                            Text("찜한 상품이 없습니다.").foregroundColor(.gray)
                        }.padding(.top, 100)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredItems) { wish in
                                // 💡 상세 페이지로 이동 시 데이터 형식 변환
                                NavigationLink(destination: ContentView(item: mapToTradeItem(wish.tradePost))) {
                                    WishlistCell(wish: wish)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("좋아요").font(.system(size: 28, weight: .bold))
                }
            }
            .onAppear { fetchWishList() } // 화면 진입 시 데이터 호출
            
            // 💡 하단 바
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    VStack { Image(systemName: "heart.fill").font(.system(size: 24)).padding(3); Text("좋아요").font(.system(size: 15)) }
                    Spacer()
                    VStack { Image(systemName: "house").font(.system(size: 24)).padding(3); Text("홈").font(.system(size: 15)) }
                    Spacer()
                    VStack {
                        Button(action: { goToChat = true }) { Image(systemName: "message").font(.system(size: 24)).padding(3) }
                        Text("채팅").font(.system(size: 15))
                    }
                    Spacer()
                }
                .padding(.top, 10).background(Color.white).shadow(color: Color.black.opacity(0.05), radius: 5, y: -2)
            }
            .fullScreenCover(isPresented: $goToChat) { ChatlistView().transition(.move(edge: .trailing)) }
        }
    }
    
    // ── 서버 데이터 호출 함수 ──
    func fetchWishList() {
        guard let url = URL(string: "http://localhost:8080/api/wishlist") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(SimpleAPIResponse<[WishListResponse]>.self, from: data)
                    if let items = decoded.data {
                        DispatchQueue.main.async { self.wishItems = items }
                    }
                } catch {
                    print("❌ 찜 목록 파싱 에러: \(error)")
                }
            }
        }.resume()
    }

    // ── 데이터 변환 헬퍼 (WishTradePost -> TradeItem) ──
    func mapToTradeItem(_ post: WishTradePost) -> TradeItem {
        return TradeItem(
            id: post.id,
            title: post.title,
            description: "",
            category: post.category,
            price: post.price,
            isPriceNegotiable: false,
            likeCount: 0, isLiked: false,
            postedAt: "방금 전",
            status: "판매 중",
            imageName: post.imageName,
            seller: TradeSellerInfo(name: post.sellerNickname, location: "서울", profileImageName: "person.circle", temperature: 36.5),
            petCategory: nil
        )
    }
}

// MARK: - 3. 서브 컴포넌트 디자인

struct CategoryChip: View {
    let title: String
    var isSelected: Bool
    var body: some View {
        Text(title).font(.system(size: 14)).padding(.horizontal, 14).padding(.vertical, 10)
            .background(Capsule().fill(isSelected ? Color(red: 0.75, green: 0.9, blue: 1.0) : Color.gray.opacity(0.15)))
            .foregroundColor(.black)
    }
}

struct WishlistCell: View {
    let wish: WishListResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // 이미지 영역
            if wish.tradePost.imageName.hasPrefix("http") {
                AsyncImage(url: URL(string: wish.tradePost.imageName)) { image in
                    image.resizable().scaledToFill()
                } placeholder: { Color.gray.opacity(0.2) }
                .frame(height: 100).clipped().cornerRadius(10)
            } else {
                Image(wish.tradePost.imageName).resizable().scaledToFill()
                    .frame(height: 100).clipped().cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(wish.tradePost.sellerNickname).font(.caption2).foregroundColor(.secondary).lineLimit(1)
                Text(wish.tradePost.title).font(.caption).bold().lineLimit(1)
                Text(wish.tradePost.price.wonFormatted)
                    .font(.caption2).fontWeight(.bold).foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 4)
        }
        .padding(8).background(Color.white).cornerRadius(12).shadow(color: .black.opacity(0.1), radius: 2)
    }
}
