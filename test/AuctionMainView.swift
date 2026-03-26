import SwiftUI

struct AuctionMainView: View {
    @State private var showActionSheet = false
    @State private var isGoUpload = false
    @State private var isGoAuction = false
    
    @State private var selectedCategory: String = "전체"
    private let categories: [String] = ["전체","전공서적","전자기기","생활용품","자취/가구","의류/잡화","식품/간식","티켓/양도","과제/자료","기타"]
    
    @State private var auctionItems: [TradePostItem] = []

    var body: some View {
        ZStack {
            NavigationLink(destination: Text("일반거래 등록"), isActive: $isGoUpload) { EmptyView() }.hidden()
            NavigationLink(destination: Text("경매 등록"), isActive: $isGoAuction) { EmptyView() }.hidden()
            
            VStack(spacing: 0) {
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

                List(auctionItems) { item in
                    NavigationLink(destination: AuctionContentView(item: item.toItem())) {
                        AuctionRow(item: item)
                    }
                }
                .listStyle(.plain)
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showActionSheet = true }) {
                        Image(systemName: "plus")
                            .font(.title.bold())
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(25)
                }
            }
        }
        .navigationTitle("경매 게시판")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("상품 등록 종류", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("일반거래") { isGoUpload = true }
            Button("경매") { isGoAuction = true }
            Button("취소", role: .cancel) { }
        }
        .onAppear {
            if auctionItems.isEmpty { loadOriginalItems() }
        }
    }
    
    func loadOriginalItems() {
        let formatter = ISO8601DateFormatter()
        let now = formatter.string(from: Date())
        
        // 테스트를 위해 마감 시간을 각각 다르게 설정 (현재 시간 기준 + @)
        let oneHourLater = formatter.string(from: Date().addingTimeInterval(3600))
        let fiveMinLater = formatter.string(from: Date().addingTimeInterval(300))
        let tomorrow = formatter.string(from: Date().addingTimeInterval(3600 * 24))

        self.auctionItems = [
            TradePostItem(id: 1, title: "빈티지 필름 카메라", price: 30000, category: "전자기기", status: "RESERVED", imageUrl: "camera.fill", sellerNickname: "카메라광", viewCount: 15, wishCount: 14, postTime: now, endTime: oneHourLater),
            TradePostItem(id: 2, title: "서울대생 애완 돌멩이", price: 18000, category: "기타", status: "RESERVED", imageUrl: "seal.fill", sellerNickname: "샤대생", viewCount: 20, wishCount: 6, postTime: now, endTime: fiveMinLater),
            TradePostItem(id: 3, title: "반질반질 윤이 나는 당근", price: 5000, category: "식품/간식", status: "RESERVED", imageUrl: "carrot.fill", sellerNickname: "농부", viewCount: 30, wishCount: 48, postTime: now, endTime: tomorrow),
            TradePostItem(id: 4, title: "국내대회 1등한 베이스 기타", price: 200000, category: "기타", status: "SOLD", imageUrl: "guitars.fill", sellerNickname: "베이시스트", viewCount: 100, wishCount: 42, postTime: now, endTime: now),
            TradePostItem(id: 5, title: "전설의 포켓몬 '뮤' 띠부씰", price: 50000, category: "기타", status: "SOLD", imageUrl: "sparkles", sellerNickname: "수집가", viewCount: 45, wishCount: 9, postTime: now, endTime: now)
        ]
    }
}

// MARK: - AuctionRow (타이머 기능 추가)
struct AuctionRow: View {
    let item: TradePostItem
    
    // ✅ 1초마다 신호를 보내는 타이머
    @State private var timeRemaining: String = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.red.opacity(0.05))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: item.imageUrl ?? "sparkles")
                            .font(.largeTitle)
                            .foregroundColor(.red.opacity(0.4))
                    )
                badgeView(for: item.status)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title).font(.system(size: 16, weight: .medium)).lineLimit(1)
                Text(relativeTimeString(from: item.postTime)).font(.system(size: 13)).foregroundColor(.secondary)
                
                // 가격 정보
                HStack(spacing: 4) {
                    Text("시작가").font(.system(size: 14)).foregroundColor(.black)
                    Text("\(formatPrice(item.price))원").font(.system(size: 17, weight: .bold)).foregroundColor(.red)
                }
                .padding(.top, 2)
                
                // 추가된 타이머 UI (시작가 밑에 배치)
                if let endTime = item.endTime, item.status == "RESERVED" {
                    HStack(spacing: 4) {
                        Image(systemName: "stopwatch").font(.system(size: 12))
                        Text(timeRemaining.isEmpty ? "계산 중..." : timeRemaining)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(.orange)
                    .onReceive(timer) { _ in
                        self.timeRemaining = calculateTimeRemaining(until: endTime)
                    }
                } else if item.status == "SOLD" {
                    Text("경매 종료").font(.system(size: 13)).foregroundColor(.gray)
                }
                
                Spacer(minLength: 0)
                
                HStack {
                    Text("조회 \(item.viewCount)").font(.system(size: 12)).foregroundColor(.gray)
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "heart").font(.system(size: 12))
                        Text("\(item.wishCount)").font(.system(size: 13))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .frame(height: 100)
        }
        .padding(.vertical, 4)
        .onAppear {
            if let endTime = item.endTime {
                self.timeRemaining = calculateTimeRemaining(until: endTime)
            }
        }
    }

    // 남은 시간 계산 함수
    private func calculateTimeRemaining(until dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let endDate = formatter.date(from: dateString) else { return "" }
        
        let diff = Int(endDate.timeIntervalSinceNow)
        
        if diff <= 0 { return "경매 종료" }
        
        let days = diff / 86400
        let hours = (diff % 86400) / 3600
        let minutes = (diff % 3600) / 60
        let seconds = diff % 60
        
        if days > 0 {
            return "\(days)일 \(hours)시간 남음"
        } else if hours > 0 {
            return "\(hours)시간 \(minutes)분 \(seconds)초 남음"
        } else {
            return "\(minutes)분 \(seconds)초 남음"
        }
    }

    @ViewBuilder
    private func badgeView(for statusString: String) -> some View {
        if let status = TradeStatus(rawValue: statusString), status != .SALE {
            let badgeInfo: (text: String, color: Color) = {
                switch status {
                case .RESERVED: return ("진행중", .red)
                case .SOLD: return ("거래완료", .gray)
                default: return ("", .clear)
                }
            }()
            
            Text(badgeInfo.text).font(.system(size: 10, weight: .bold)).foregroundColor(.white).padding(.horizontal, 6).padding(.vertical, 3).background(badgeInfo.color).cornerRadius(4).padding(5)
        }
    }
    
    private func formatPrice(_ price: Int) -> String {
        let formatter = NumberFormatter(); formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }

    func relativeTimeString(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter(); guard let date = formatter.date(from: dateString) else { return "방금 전" }
        let now = Date(); let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        if let day = components.day, day > 0 { return "\(day)일 전" }
        if let hour = components.hour, hour > 0 { return "\(hour)시간 전" }
        if let minute = components.minute, minute > 0 { return "\(minute)분 전" }
        return "방금 전"
    }
}
#Preview {
    NavigationStack {
        AuctionMainView()
    }
}
