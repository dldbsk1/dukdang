import SwiftUI

// 💡 1. 백엔드의 JSON 응답 구조를 받을 Swift 모델(Codable)
struct APIResponse<T: Codable>: Codable {
    let status: Int?
    let message: String?
    let data: PageData<T>?
}

struct PageData<T: Codable>: Codable {
    let content: [T]
}

struct TradePostItem: Codable {
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

// 💡 2. 뷰에서 사용할 Product 구조체 (상태와 카테고리 추가!)
struct Product: Identifiable {
    let id: Int
    let title: String
    let price: String
    let newPrice: String
    let time: String
    let heartCount: Int
    let imageName: String
    let status: String   // 💡 추가됨 (SALE, SOLD 등)
    let category: String // 💡 추가됨
}

struct MainView: View {
    @State private var showActionSheet = false
    @State private var isGoUpload = false
    @State private var isGoAuction = false
    @State private var isGoMyPage = false
    
    @State private var selectedCategory: String = "전체"
    private let categories: [String] = ["전체","학습교재","디지털기기", "생활용품", "의류", "기타"]
    
    @State private var products: [Product] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 네비게이션 링크들
                NavigationLink(destination: AddView(), isActive: $isGoUpload) { EmptyView() }.hidden()
                NavigationLink(destination: Text("경매 등록 뷰 (추후 구현)"), isActive: $isGoAuction) { EmptyView() }.hidden()
                NavigationLink(destination: MypageView(), isActive: $isGoMyPage) { EmptyView() }.hidden()
                
                VStack(spacing: 0) {
                    // 카테고리 필터
                    HStack {
                        Menu {
                            ForEach(categories, id: \.self) { category in
                                Button(category) { selectedCategory = category }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(selectedCategory)").font(.system(size: 16, weight: .bold))
                                Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .padding(10)
                        }
                        Spacer()
                    }
                    Divider()
                    
                    // 게시물 리스트 (상세화면 연결)
                    List(products) { product in
                        NavigationLink(destination: ContentView(item: convertToTradeItem(product))) {
                            ProductRow(product: product)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        fetchPosts()
                    }
                    
                    Spacer()
                }
                
                // 플로팅 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showActionSheet = true }) {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.cyan)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(25)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isGoMyPage = true }) {
                        Image(systemName: "person").foregroundColor(.black)
                    }
                }
            }
            .onAppear {
                fetchPosts()
            }
            .confirmationDialog("상품 등록 종류", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("일반거래") { isGoUpload = true }
                Button("경매") { isGoUpload = true }
                Button("취소", role: .cancel) { }
            } message: {
                Text("원하시는 거래 방식을 선택해주세요.")
            }
        }
    }
    
    // ────────────────────────────────────────
    // 백엔드에서 게시글 목록 불러오는 함수
    // ────────────────────────────────────────
    func fetchPosts() {
        guard let url = URL(string: "http://localhost:8080/trade-posts?size=20") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("네트워크 에러: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            
            do {
                let decoded = try JSONDecoder().decode(APIResponse<TradePostItem>.self, from: data)
                
                if let content = decoded.data?.content {
                    DispatchQueue.main.async {
                        self.products = content.map { item in
                            // 💡 빈 문자열("")로 오면 앱이 튕기므로 안전장치 추가!
                            let img = (item.imageUrl == nil || item.imageUrl == "") ? "photo" : item.imageUrl!
                            
                            return Product(
                                id: item.id,
                                title: item.title,
                                price: "",
                                newPrice: "\(item.price)원",
                                time: String(item.postTime.prefix(10)),
                                heartCount: item.wishCount,
                                imageName: img,         // 💡 안전한 썸네일 투입
                                status: item.status,    // 💡 진짜 상태
                                category: item.category // 💡 진짜 카테고리
                            )
                        }
                    }
                }
            } catch {
                print("디코딩 에러: \(error)")
            }
        }.resume()
    }
    
    // ────────────────────────────────────────
    // 💡 Product를 ContentView에서 쓰는 TradeItem으로 바꿔주는 함수
    // ────────────────────────────────────────
    func convertToTradeItem(_ product: Product) -> TradeItem {
        // 백엔드 영문 상태를 한글로 예쁘게 변환
        let uiStatus = product.status == "SALE" ? "판매중" : (product.status == "SOLD" ? "거래완료" : "예약중")
        
        return TradeItem(
            id: product.id,
            title: product.title,
            description: "상세 설명입니다.", // 👈 어차피 ContentView가 서버에서 진짜 설명을 다시 불러옵니다!
            category: product.category, // 💡 진짜 카테고리 적용
            price: Int(product.newPrice.replacingOccurrences(of: "원", with: "")) ?? 0,
            isPriceNegotiable: true,
            likeCount: product.heartCount,
            isLiked: false,
            postedAt: product.time,
            status: uiStatus, // 💡 진짜 한글 상태 적용
            imageName: product.imageName,
            seller: TradeSellerInfo(name: "판매자", location: "동네 미설정", profileImageName: "person.circle", temperature: 36.5),
            petCategory: nil
        )
    }
} // MainView 끝

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// ProductRow
struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            
            if product.imageName.hasPrefix("http") {
                AsyncImage(url: URL(string: product.imageName)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: product.imageName)
                            .font(.largeTitle)
                            .foregroundColor(.gray.opacity(0.5))
                    )
            }
            
            VStack(alignment: .leading, spacing: 5) {
                // 💡 [수정] 상태 뱃지와 제목을 나란히 배치!
                HStack(spacing: 5) {
                    if product.status != "SALE" {
                        Text(product.status == "SOLD" ? "거래완료" : "예약중")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(product.status == "SOLD" ? Color.gray : Color.green)
                            .cornerRadius(4)
                    }
                    Text(product.title)
                        .font(.system(size: 16, weight: .medium))
                        .lineLimit(1)
                }
                
                Text("#덕성여대 • \(product.time)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    if !product.price.isEmpty {
                        Text(product.price)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .strikethrough(true, color: .gray)
                    }
                    
                    Text(product.newPrice)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.cyan)
                }
                
                Spacer(minLength: 0)
                
                HStack {
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "heart").font(.system(size: 12))
                        Text("\(product.heartCount)").font(.system(size: 13))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .frame(height: 100)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MainView()
}
