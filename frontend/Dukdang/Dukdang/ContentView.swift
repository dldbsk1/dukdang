import SwiftUI

// MARK: - 1. API 응답 구조체 정의
struct ChatRoomResponse: Codable {
    let roomId: Int
    let otherUserNickname: String
}

struct TradePostDetailResponse: Codable {
    let description: String
    let sellerNickname: String
    let imageUrls: [String]?
    let sellerProfileImageUrl: String?
}

// MARK: - 2. 데이터 모델
struct TradeItem: Identifiable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let price: Int
    let isPriceNegotiable: Bool
    let likeCount: Int
    let isLiked: Bool
    let postedAt: String
    let status: String
    let imageName: String
    let seller: TradeSellerInfo
    let petCategory: String?
}

struct TradeSellerInfo {
    let name: String
    let location: String
    let profileImageName: String
    let temperature: Double
}

// MARK: - 3. 메인 상세 뷰
struct ContentView: View {
    @State private var isLiked: Bool = false
    @State private var currentLikeCount: Int = 0
    @State private var isGoChat = false
    @State private var selectedRoomId: Int? = nil
    
    @State private var realDescription: String = ""
    @State private var realSellerName: String = ""
    @State private var realImageUrls: [String] = []
    @State private var realSellerProfileImage: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    let item: TradeItem

    var displayImages: [String] {
        return realImageUrls.isEmpty ? [item.imageName] : realImageUrls
    }

    var body: some View {
        VStack(spacing: 0) {
            
            // 상단 이미지 영역
            TabView {
                ForEach(displayImages, id: \.self) { imgUrl in
                    if imgUrl.hasPrefix("http") {
                        AsyncImage(url: URL(string: imgUrl)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: { Color.gray.opacity(0.3) }
                        .frame(height: 300).clipped()
                    } else {
                        Image(imgUrl).resizable().scaledToFill().frame(height: 300).clipped()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 300)
            .overlay(
                HStack {
                    Button(action: { dismiss() }) { Image(systemName: "chevron.left").modifier(TopButtonModifier()) }
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "house").modifier(TopButtonModifier())
                        Image(systemName: "square.and.arrow.up").modifier(TopButtonModifier())
                    }
                }
                .padding(.horizontal, 16).padding(.top, 55),
                alignment: .top
            )
            
            // 본문 영역
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    SellerProfileView(seller: realSellerName.isEmpty ? item.seller : TradeSellerInfo(name: realSellerName, location: "", profileImageName: realSellerProfileImage, temperature: 36.5))
                    
                    Divider()
                    
                    Text(item.status).font(.caption).padding(6).background(Color.gray.opacity(0.2)).cornerRadius(5)
                    HStack {
                        Text(item.title).font(.title3).bold()
                        Spacer()
                        Text("\(item.category) · \(item.postedAt)").font(.caption).foregroundColor(.gray)
                    }
                    
                    Text(realDescription.isEmpty ? item.description : realDescription)
                        .font(.body)
                        .padding(.vertical, 10)
                }
                .padding()
            }

            Divider()
            
            // 하단 바
            HStack {
                VStack(alignment: .center) {
                    Button(action: { toggleLike() }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.title2)
                            .foregroundColor(isLiked ? .red : .gray)
                    }
                    Text("\(currentLikeCount)").font(.caption).foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text("가격").font(.caption).foregroundColor(.gray)
                    Text(item.price.wonFormatted).font(.title2).bold()
                }
                Spacer()
                
                Button(action: { createChatRoom() }) {
                    Text("채팅 하기")
                        .font(.title2).bold().foregroundColor(.white)
                        .padding().frame(maxWidth: 200).background(Color.blue).cornerRadius(8)
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.isLiked = item.isLiked
            self.currentLikeCount = item.likeCount
            checkInitialLikeStatus()
            fetchPostDetails()
        }
        .navigationDestination(isPresented: $isGoChat) {
            if let roomId = selectedRoomId {
                ChatitemView(
                    roomId: roomId,
                    productTitle: item.title,
                    productPrice: item.price.wonFormatted,
                    productImageUrl: displayImages.first,
                    sellerId: 1
                )
            }
        }
    }

    // MARK: - 4. 로직 함수
    func fetchPostDetails() {
        guard let url = URL(string: "http://localhost:8080/trade-posts/\(item.id)") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(SimpleAPIResponse<TradePostDetailResponse>.self, from: data) {
                DispatchQueue.main.async {
                    if let detail = decoded.data {
                        self.realDescription = detail.description
                        self.realSellerName = detail.sellerNickname
                        self.realImageUrls = detail.imageUrls ?? []
                        self.realSellerProfileImage = detail.sellerProfileImageUrl ?? ""
                    }
                }
            }
        }.resume()
    }

    func checkInitialLikeStatus() {
        guard let url = URL(string: "http://localhost:8080/api/wishlist/check/\(item.id)") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(SimpleAPIResponse<Bool>.self, from: data) {
                DispatchQueue.main.async {
                    self.isLiked = decoded.data ?? false
                }
            }
        }.resume()
    }

    func toggleLike() {
        guard let url = URL(string: "http://localhost:8080/api/wishlist/\(item.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data,
               let decoded = try? JSONDecoder().decode(SimpleAPIResponse<Bool>.self, from: data) {
                DispatchQueue.main.async {
                    if let newStatus = decoded.data {
                        self.isLiked = newStatus
                        if newStatus {
                            self.currentLikeCount += 1
                        } else {
                            self.currentLikeCount = max(0, self.currentLikeCount - 1)
                        }
                    }
                }
            }
        }.resume()
    }

    func createChatRoom() {
        guard let url = URL(string: "http://localhost:8080/chat/rooms/trade-posts/\(item.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else { return }
            do {
                let decoded = try JSONDecoder().decode(SimpleAPIResponse<ChatRoomResponse>.self, from: data)
                if let roomData = decoded.data {
                    DispatchQueue.main.async {
                        self.selectedRoomId = roomData.roomId
                        self.isGoChat = true
                    }
                }
            } catch {
                print("❌ 채팅방 생성 파싱 에러: \(error)")
            }
        }.resume()
    }
}

// MARK: - 5. 헬퍼 모디파이어 및 뷰
extension Int {
    var wonFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        if let formatted = formatter.string(from: NSNumber(value: self)) { return "\(formatted)원" }
        return "\(self)원"
    }
}

struct TopButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .padding(10)
            .background(Color.black.opacity(0.4))
            .clipShape(Circle())
    }
}

struct SellerProfileView: View {
    let seller: TradeSellerInfo
    var body: some View {
        HStack {
            if seller.profileImageName.hasPrefix("http") {
                AsyncImage(url: URL(string: seller.profileImageName)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(seller.profileImageName.isEmpty ? "person.circle.fill" : seller.profileImageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundColor(.gray.opacity(0.3))
            }
            
            VStack(alignment: .leading) {
                Text(seller.name).font(.headline)
                // 💡 [수정] 동네 미설정 표시를 날렸습니다!
            }
            Spacer()
        }
    }
}
