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

// 💡 2. 뷰에서 사용할 Product 구조체
struct Product: Identifiable {
    let id: Int
    let title: String
    let price: String
    let newPrice: String
    let time: String
    let heartCount: Int
    let imageName: String
    let status: String
    let category: String
}

struct MainView: View {
    @State private var showActionSheet = false
    @State private var isGoUpload = false
    @State private var isGoAuction = false
    @State private var isGoMyPage = false
    
    // 💡 [핵심 추가] 백엔드 영문 카테고리와 화면의 한글 카테고리를 연결하는 매핑 사전!
    @State private var selectedCategory: String = "전체"
    private let categories: [String] = ["전체", "의류/잡화", "서적", "전자기기", "생활용품", "자취/가구", "식품/간식", "티켓/양도", "과제/자료", "기타"]
    private var categoryMap: [String: String] {
        ["의류/잡화": "FASHION", "서적": "BOOK", "전자기기": "ELECTRONICS",
         "생활용품": "LIVING", "자취/가구": "FURNITURE", "식품/간식": "FOOD",
         "티켓/양도": "TICKET", "과제/자료": "ASSIGNMENT", "기타": "ETC"]
    }
    
    @State private var products: [Product] = []
    
    // 💡 [핵심 추가] 현재 선택된 카테고리만 쏙쏙 뽑아주는 거름망!
    var filteredProducts: [Product] {
        if selectedCategory == "전체" {
            return products
        } else {
            let targetBackendCategory = categoryMap[selectedCategory] ?? "ETC"
            return products.filter { $0.category == targetBackendCategory }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink(destination: AddView(), isActive: $isGoUpload) { EmptyView() }.hidden()
                NavigationLink(destination: AuctionAddView(), isActive: $isGoAuction) { EmptyView() }.hidden()
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
                    
                    // 💡 [핵심 수정] 그냥 products 대신 거름망(filteredProducts)을 연결!
                    List(filteredProducts) { product in
                        NavigationLink(destination: ContentView(item: convertToTradeItem(product))) {
                            ProductRow(product: product)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { fetchPosts() }
                    
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
            .onAppear { fetchPosts() }
            .confirmationDialog("상품 등록 종류", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("일반거래") { isGoUpload = true }
                Button("경매") { isGoAuction = true }
                Button("취소", role: .cancel) { }
            } message: {
                Text("원하시는 거래 방식을 선택해주세요.")
            }
        }
    }
    
    func fetchPosts() {
        guard let url = URL(string: "http://localhost:8080/trade-posts?size=20") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { print("네트워크 에러: \(error.localizedDescription)"); return }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(APIResponse<TradePostItem>.self, from: data)
                if let content = decoded.data?.content {
                    DispatchQueue.main.async {
                        let formatter = NumberFormatter()
                        formatter.numberStyle = .decimal
                        self.products = content.map { item in
                            let img = (item.imageUrl == nil || item.imageUrl == "") ? "photo" : item.imageUrl!
                            let formattedPrice = formatter.string(from: NSNumber(value: item.price)) ?? "\(item.price)"
                            
                            return Product(
                                id: item.id, title: item.title, price: "", newPrice: "\(formattedPrice)원",
                                time: String(item.postTime.prefix(10)), heartCount: item.wishCount,
                                imageName: img, status: item.status, category: item.category
                            )
                        }
                    }
                }
            } catch { print("디코딩 에러: \(error)") }
        }.resume()
    }
    
    func convertToTradeItem(_ product: Product) -> TradeItem {
        let uiStatus = product.status == "SALE" ? "판매중" : (product.status == "SOLD" ? "거래완료" : "예약중")
        let pureNumberString = product.newPrice.replacingOccurrences(of: "원", with: "").replacingOccurrences(of: ",", with: "")
        
        return TradeItem(
            id: product.id, title: product.title, description: "상세 설명입니다.", category: product.category,
            price: Int(pureNumberString) ?? 0, isPriceNegotiable: true, likeCount: product.heartCount,
            isLiked: false, postedAt: product.time, status: uiStatus, imageName: product.imageName,
            seller: TradeSellerInfo(name: "판매자", location: "동네 미설정", profileImageName: "person.circle", temperature: 36.5),
            petCategory: nil
        )
    }
}

struct ProductRow: View {
    let product: Product
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            if product.imageName.hasPrefix("http") {
                AsyncImage(url: URL(string: product.imageName)) { image in image.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.3) }
                .frame(width: 100, height: 100).clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)).frame(width: 100, height: 100)
                    .overlay(Image(systemName: product.imageName).font(.largeTitle).foregroundColor(.gray.opacity(0.5)))
            }
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 5) {
                    if product.status != "SALE" {
                        Text(product.status == "SOLD" ? "거래완료" : "예약중")
                            .font(.system(size: 11, weight: .bold)).foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 3)
                            .background(product.status == "SOLD" ? Color.gray : Color.green).cornerRadius(4)
                    }
                    Text(product.title).font(.system(size: 16, weight: .medium)).lineLimit(1)
                }
                Text("#덕성여대 • \(product.time)").font(.system(size: 13)).foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    if !product.price.isEmpty { Text(product.price).font(.system(size: 14)).foregroundColor(.gray).strikethrough(true, color: .gray) }
                    Text(product.newPrice).font(.system(size: 17, weight: .bold)).foregroundColor(.cyan)
                }
                Spacer(minLength: 0)
                HStack { Spacer(); HStack(spacing: 3) { Image(systemName: "heart").font(.system(size: 12)); Text("\(product.heartCount)").font(.system(size: 13)) }.foregroundColor(.secondary) }
            }.frame(height: 100)
        }.padding(.vertical, 4)
    }
}
