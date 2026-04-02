import SwiftUI

// 💡 경매 API 응답 모델
struct AuctionListResponse: Codable, Identifiable {
    let id: Int
    let title: String
    let minPrice: Int
    let currentHighestPrice: Int?
    let category: String
    let status: String
    let imageUrl: String?
    let sellerNickname: String
    let bidCount: Int
    let startTime: String
    let endTime: String
    let postTime: String
}

struct AuctionMainView: View {
    @State private var showActionSheet = false
    @State private var isGoUpload = false
    @State private var isGoAuction = false
    
    // 💡 [핵심 추가] 백엔드 영문 카테고리와 화면의 한글 카테고리를 연결하는 매핑 사전!
    @State private var selectedCategory: String = "전체"
    private let categories: [String] = ["전체", "의류/잡화", "서적", "전자기기", "생활용품", "자취/가구", "식품/간식", "티켓/양도", "과제/자료", "기타"]
    private var categoryMap: [String: String] {
        ["의류/잡화": "FASHION", "서적": "BOOK", "전자기기": "ELECTRONICS",
         "생활용품": "LIVING", "자취/가구": "FURNITURE", "식품/간식": "FOOD",
         "티켓/양도": "TICKET", "과제/자료": "ASSIGNMENT", "기타": "ETC"]
    }
    
    @State private var auctionItems: [AuctionListResponse] = []

    // 💡 [핵심 추가] 현재 선택된 카테고리만 쏙쏙 뽑아주는 거름망!
    var filteredAuctions: [AuctionListResponse] {
        if selectedCategory == "전체" {
            return auctionItems
        } else {
            let targetBackendCategory = categoryMap[selectedCategory] ?? "ETC"
            return auctionItems.filter { $0.category == targetBackendCategory }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Menu { ForEach(categories, id: \.self) { category in Button(category) { selectedCategory = category } } } label: {
                            HStack(spacing: 4) { Text("\(selectedCategory)").font(.system(size: 16, weight: .bold)); Image(systemName: "chevron.down").font(.system(size: 12, weight: .bold)) }
                            .foregroundColor(.black).padding(10)
                        }
                        Spacer()
                    }
                    Divider()

                    // 💡 [핵심 수정] 그냥 auctionItems 대신 거름망(filteredAuctions)을 연결!
                    List(filteredAuctions) { item in
                        NavigationLink(destination: AuctionContentView(item: item)) {
                            AuctionRow(item: item)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { fetchAuctions() }
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showActionSheet = true }) {
                            Image(systemName: "plus").font(.title.bold()).foregroundColor(.white)
                                .frame(width: 60, height: 60).background(Color.red).clipShape(Circle()).shadow(radius: 4)
                        }.padding(25)
                    }
                }
            }
            .navigationTitle("경매 게시판").navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("상품 등록 종류", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("일반거래") { isGoUpload = true }
                Button("경매") { isGoAuction = true }
                Button("취소", role: .cancel) { }
            }
            .onAppear { fetchAuctions() }
            .navigationDestination(isPresented: $isGoUpload) { AddView() }
            .navigationDestination(isPresented: $isGoAuction) { AuctionAddView() }
        }
    }
    
    func fetchAuctions() {
        guard let url = URL(string: "http://localhost:8080/auctions?size=20") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(APIResponse<AuctionListResponse>.self, from: data) {
                DispatchQueue.main.async { self.auctionItems = decoded.data?.content ?? [] }
            }
        }.resume()
    }
}

// MARK: - AuctionRow
struct AuctionRow: View {
    let item: AuctionListResponse
    @State private var timeRemaining: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack(alignment: .topLeading) {
                let img = item.imageUrl ?? "sparkles"
                if img.hasPrefix("http") {
                    AsyncImage(url: URL(string: img)) { image in image.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.3) }
                    .frame(width: 100, height: 100).clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.05)).frame(width: 100, height: 100)
                        .overlay(Image(systemName: img).font(.largeTitle).foregroundColor(.red.opacity(0.4)))
                }
                badgeView(for: item.status)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title).font(.system(size: 16, weight: .medium)).lineLimit(1)
                Text(relativeTimeString(from: item.postTime)).font(.system(size: 13)).foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text("시작가").font(.system(size: 14)).foregroundColor(.black)
                    Text("\(item.minPrice.wonFormatted)").font(.system(size: 17, weight: .bold)).foregroundColor(.red)
                }.padding(.top, 2)
                
                if item.status == "RESERVED" || item.status == "ACTIVE" {
                    HStack(spacing: 4) {
                        Image(systemName: "stopwatch").font(.system(size: 12))
                        Text(timeRemaining.isEmpty ? "계산 중..." : timeRemaining).font(.system(size: 13, weight: .semibold))
                    }.foregroundColor(.orange)
                    .onReceive(timer) { _ in self.timeRemaining = calculateTimeRemaining(until: item.endTime) }
                } else if item.status == "SOLD" || item.status == "ENDED" || item.status == "COMPLETED" {
                    Text("경매 종료").font(.system(size: 13)).foregroundColor(.gray)
                }
                Spacer(minLength: 0)
                
                HStack {
                    Spacer()
                    HStack(spacing: 3) { Image(systemName: "hand.raised.fill").font(.system(size: 12)); Text("\(item.bidCount)") }.foregroundColor(.secondary)
                }
            }.frame(height: 100)
        }.padding(.vertical, 4)
        .onAppear { self.timeRemaining = calculateTimeRemaining(until: item.endTime) }
    }

    private func parseDate(_ dateStr: String) -> Date? {
        let formatter = DateFormatter(); formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = formatter.date(from: dateStr) { return d }; formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"; return formatter.date(from: dateStr)
    }

    private func calculateTimeRemaining(until dateString: String) -> String {
        guard let endDate = parseDate(dateString) else { return "마감" }
        let diff = Int(endDate.timeIntervalSinceNow); if diff <= 0 { return "경매 종료" }
        let days = diff / 86400; let hours = (diff % 86400) / 3600; let minutes = (diff % 3600) / 60; let seconds = diff % 60
        if days > 0 { return "\(days)일 \(hours)시간 남음" } else if hours > 0 { return "\(hours)시간 \(minutes)분 \(seconds)초 남음" } else { return "\(minutes)분 \(seconds)초 남음" }
    }
    
    @ViewBuilder private func badgeView(for statusString: String) -> some View {
        if statusString != "WAITING" {
            let badgeInfo: (text: String, color: Color) = {
                switch statusString {
                case "ACTIVE": return ("진행중", .red)
                case "ENDED", "COMPLETED": return ("거래완료", .gray)
                    // 💡 [핵심 추가] 유찰(CANCELLED) 상태일 때 검은색 배경의 '유찰' 뱃지 표시
                case "CANCELLED": return ("유찰", .black)
                default: return ("", .clear)
                }
            }()
            // text가 비어있지 않은 경우에만 뱃지 렌더링
            if !badgeInfo.text.isEmpty {
                Text(badgeInfo.text)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(badgeInfo.color)
                    .cornerRadius(4)
                    .padding(5)
            }
        }
    }
    func relativeTimeString(from dateString: String) -> String {
        guard let date = parseDate(dateString) else { return "방금 전" }
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: Date())
        if let d = components.day, d > 0 { return "\(d)일 전" }; if let h = components.hour, h > 0 { return "\(h)시간 전" }; if let m = components.minute, m > 0 { return "\(m)분 전" }; return "방금 전"
    }
}
