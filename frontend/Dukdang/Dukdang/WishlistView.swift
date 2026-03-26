import SwiftUI
import Foundation

// 💡 1. 백엔드의 TradePostListResponseDto 구조에 완벽하게 맞춘 모델로 교체!
struct WishTradePostItem: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Int
    let category: String
    let status: String
    let imageUrl: String?
    let sellerNickname: String
    let viewCount: Int
    let wishCount: Int
    let postTime: String
}

// MARK: - 2. 메인 뷰
struct WishlistView: View {
    @State private var wishItems: [WishTradePostItem] = [] // 💡 진짜 데이터 배열
    @State private var selectedCategory: String = "전체"
    
    let categories = ["전체", "의류", "신발", "가방", "뷰티"]
    
    // 💡 그리드 레이아웃 정의 (3열)
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // 💡 카테고리 필터링 로직
    var filteredItems: [WishTradePostItem] {
        if selectedCategory == "전체" {
            return wishItems
        } else {
            return wishItems.filter { $0.category == selectedCategory }
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
                                // 💡 상세 페이지로 이동 시 완벽한 TradeItem으로 변환
                                NavigationLink(destination: ContentView(item: mapToTradeItem(wish))) {
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
        }
    }
    
    // ── 서버 데이터 호출 함수 ──
    func fetchWishList() {
        // 💡 [핵심 수정] 완벽한 데이터를 주는 /trade-posts/my-wishes API로 변경!
        guard let url = URL(string: "http://localhost:8080/trade-posts/my-wishes") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(SimpleAPIResponse<[WishTradePostItem]>.self, from: data)
                    if let items = decoded.data {
                        DispatchQueue.main.async { self.wishItems = items }
                    }
                } catch {
                    print("❌ 찜 목록 파싱 에러: \(error)")
                }
            }
        }.resume()
    }

    // ── 데이터 변환 헬퍼 (WishTradePostItem -> TradeItem) ──
    func mapToTradeItem(_ post: WishTradePostItem) -> TradeItem {
        // 💡 [핵심 수정] 가짜 데이터 대신, 메인 화면과 완벽히 동일하게 진짜 상태/날짜/하트를 넣습니다!
        let uiStatus = post.status == "SALE" ? "판매중" : (post.status == "SOLD" ? "거래완료" : "예약중")
        let img = (post.imageUrl == nil || post.imageUrl == "") ? "photo" : post.imageUrl!
        let timeString = String(post.postTime.prefix(10))

        return TradeItem(
            id: post.id,
            title: post.title,
            description: "상세 설명입니다.", // 어차피 ContentView가 다시 불러옴
            category: post.category,
            price: post.price,
            isPriceNegotiable: true,
            likeCount: post.wishCount, // 💡 진짜 하트 개수!
            isLiked: true,             // 내 위시리스트에 있으니 당연히 하트 켜짐!
            postedAt: timeString,      // 💡 진짜 작성 날짜!
            status: uiStatus,          // 💡 진짜 상태(판매중/거래완료)!
            imageName: img,
            seller: TradeSellerInfo(name: post.sellerNickname, location: "동네 미설정", profileImageName: "person.circle", temperature: 36.5),
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
    let wish: WishTradePostItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            let img = (wish.imageUrl == nil || wish.imageUrl == "") ? "photo" : wish.imageUrl!
            
            // 이미지 영역
            if img.hasPrefix("http") {
                AsyncImage(url: URL(string: img)) { image in
                    image.resizable().scaledToFill()
                } placeholder: { Color.gray.opacity(0.2) }
                .frame(height: 100).clipped().cornerRadius(10)
            } else {
                Image(img).resizable().scaledToFill()
                    .frame(height: 100).clipped().cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(wish.sellerNickname).font(.caption2).foregroundColor(.secondary).lineLimit(1)
                Text(wish.title).font(.caption).bold().lineLimit(1)
                Text(wish.price.wonFormatted)
                    .font(.caption2).fontWeight(.bold).foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 4)
        }
        .padding(8).background(Color.white).cornerRadius(12).shadow(color: .black.opacity(0.1), radius: 2)
    }
}
