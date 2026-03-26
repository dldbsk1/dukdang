import SwiftUI

// API 상세 모델
struct AuctionDetailResponse: Codable {
    let description: String
    let imageUrls: [String]?
    let currentHighestPrice: Int?
    let sellerId: Int?
    let sellerProfileImageUrl: String?}

struct AuctionContentView: View {
    let item: AuctionListResponse
    @State private var showBidSheet = false
    @State private var isLiked: Bool = false
    @State private var realSellerProfileImage: String = ""
    
    @State private var realDescription: String = ""
    @State private var realImageUrls: [String] = []
    @State private var currentPrice: Int = 0
    
    @State private var isMyAuction: Bool = false
    @State private var isPriceHidden: Bool = false
    
    @State private var timeRemaining: String = "계산 중..."
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.dismiss) private var dismiss
    
    var displayImages: [String] {
        return realImageUrls.isEmpty ? [item.imageUrl ?? "sparkles"] : realImageUrls
    }
    
    var isAuctionEnded: Bool {
        item.status == "ENDED" || item.status == "COMPLETED" || item.status == "CANCELLED" || timeRemaining == "경매 종료"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TabView {
                        ForEach(displayImages, id: \.self) { imgUrl in
                            if imgUrl.hasPrefix("http") {
                                AsyncImage(url: URL(string: imgUrl)) { image in image.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.3) }.frame(height: 300).clipped()
                            } else {
                                Image(systemName: imgUrl).font(.system(size: 80)).foregroundColor(.red.opacity(0.4)).frame(height: 300)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle()).frame(height: 300)
                    .overlay(
                        HStack { Button(action: { dismiss() }) { Image(systemName: "chevron.left").modifier(TopButtonModifier()) }; Spacer() }.padding(.horizontal, 16).padding(.top, 55), alignment: .top
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            // 💡 [핵심 수정] 회색 아이콘 대신 실제 프로필 사진을 띄웁니다!
                            if realSellerProfileImage.hasPrefix("http") {
                                AsyncImage(url: URL(string: realSellerProfileImage)) { image in
                                    image.resizable().scaledToFill()
                                } placeholder: { Color.gray.opacity(0.2) }
                                .frame(width: 40, height: 40).clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill").resizable()
                                    .frame(width: 40, height: 40).foregroundColor(.gray.opacity(0.5))
                            }
                            VStack(alignment: .leading) { Text(item.sellerNickname).font(.headline); Text("인증된 판매자").font(.caption).foregroundColor(.gray) }
                            Spacer()
                        }.padding(.vertical, 8)
                        
                        Divider(); badgeView(for: item.status)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.title).font(.title3).bold()
                            HStack { Text(item.category).font(.caption); Text("•"); Text(relativeTimeString(from: item.postTime)).font(.caption) }.foregroundColor(.secondary)
                        }
                        
                        Text(realDescription.isEmpty ? "상세 정보 불러오는 중..." : realDescription).font(.body).padding(.vertical, 10)
                        
                        if item.status == "ACTIVE" || item.status == "WAITING" {
                            HStack { Spacer(); Image(systemName: "stopwatch.fill"); Text(timeRemaining).fontWeight(.bold); Spacer() }
                            .font(.system(size: 18)).foregroundColor(.orange).padding(.vertical, 10).background(Color.orange.opacity(0.08)).cornerRadius(10)
                            .onReceive(timer) { _ in self.timeRemaining = calculateTimeRemaining(until: item.endTime) }
                        }

                        HStack {
                            Spacer()
                            Text("현재 최고가").font(.title3).foregroundColor(.gray)
                            Spacer()
                            
                            if isPriceHidden {
                                Text("블라인드 (종료 후 공개)")
                                    .font(.headline).bold().foregroundColor(.red)
                            } else {
                                Text("\(currentPrice.wonFormatted)").font(.title).bold()
                            }
                            
                            Spacer()
                        }
                        .padding().background(Color.gray.opacity(0.1)).cornerRadius(10)
                        
                        // 💡 [핵심 수정] 조회수 표시 코드를 완전히 삭제했습니다!
                    }.padding()
                }
            }
            
            Divider()
            HStack {
                Button(action: { showBidSheet = true }) {
                    Text(isAuctionEnded ? "경매 종료" : (isMyAuction ? "내 경매 (입찰 불가)" : "가격 올리기"))
                        .font(.title2).bold().foregroundColor(.white).frame(maxWidth: .infinity).padding()
                        .background(isAuctionEnded || isMyAuction ? Color.gray : Color.red).cornerRadius(8)
                }.disabled(isAuctionEnded || isMyAuction)
            }.padding()
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.currentPrice = item.currentHighestPrice ?? item.minPrice
            self.timeRemaining = calculateTimeRemaining(until: item.endTime)
            fetchDetails()
        }
        .sheet(isPresented: $showBidSheet) {
            BidSheetView(auctionId: item.id, currentPrice: currentPrice, isPresented: $showBidSheet) { fetchDetails() }
        }
    }
    
    func fetchDetails() {
        guard let url = URL(string: "http://localhost:8080/auctions/\(item.id)") else { return }
        var req = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        
        URLSession.shared.dataTask(with: req) { data, _, _ in
            if let data = data, let dec = try? JSONDecoder().decode(SimpleAPIResponse<AuctionDetailResponse>.self, from: data) {
                DispatchQueue.main.async {
                    if let d = dec.data {
                        self.realDescription = d.description
                        self.realImageUrls = d.imageUrls ?? []
                        
                        // 💡 [이 부분!] 서버에서 받아온 판매자 프사 주소를 변수에 저장합니다!
                        self.realSellerProfileImage = d.sellerProfileImageUrl ?? ""
                        
                        let myUserId = UserDefaults.standard.integer(forKey: "myUserId")
                        if let sId = d.sellerId { self.isMyAuction = (sId == myUserId) }
                        
                        if let h = d.currentHighestPrice {
                            self.currentPrice = h
                            self.isPriceHidden = false
                        } else {
                            if self.isMyAuction && !self.isAuctionEnded { self.isPriceHidden = true }
                            else { self.currentPrice = item.minPrice; self.isPriceHidden = false }
                        }
                    }
                }
            }
        }.resume()
    }
    private func parseDate(_ dateStr: String) -> Date? {
        let formatter = DateFormatter(); formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = formatter.date(from: dateStr) { return d }; formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"; return formatter.date(from: dateStr)
    }

    private func calculateTimeRemaining(until dateString: String) -> String {
        guard let endDate = parseDate(dateString) else { return "시간 파싱 오류" }
        let diff = Int(endDate.timeIntervalSinceNow); if diff <= 0 { return "경매 종료" }
        let days = diff / 86400; let hours = (diff % 86400) / 3600; let minutes = (diff % 3600) / 60; let seconds = diff % 60
        if days > 0 { return "마감까지 \(days)일 \(hours)시간" } else { return String(format: "마감까지 %02d:%02d:%02d", hours, minutes, seconds) }
    }
    @ViewBuilder private func badgeView(for statusString: String) -> some View {
        if statusString != "WAITING" {
            let badgeInfo: (text: String, color: Color) = { switch statusString { case "ACTIVE": return ("진행중", .red); case "ENDED", "COMPLETED": return ("거래완료", .gray); case "CANCELLED": return ("유찰", .black); default: return ("", .clear) } }()
            Text(badgeInfo.text).font(.system(size: 11, weight: .bold)).foregroundColor(.white).padding(.horizontal, 8).padding(.vertical, 4).background(badgeInfo.color).cornerRadius(4)
        }
    }
    func relativeTimeString(from dateString: String) -> String {
        guard let date = parseDate(dateString) else { return "방금 전" }
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: Date())
        if let d = components.day, d > 0 { return "\(d)일 전" }; if let h = components.hour, h > 0 { return "\(h)시간 전" }; if let m = components.minute, m > 0 { return "\(m)분 전" }; return "방금 전"
    }
}

// 입찰 바텀 시트
struct BidSheetView: View {
    let auctionId: Int; let currentPrice: Int; @Binding var isPresented: Bool; var onBidSuccess: () -> Void
    @State private var bidInput: String = ""; @State private var alertMessage = ""; @State private var showAlert = false
    let quickBids = [100, 500, 1000, 5000]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("가격 올리기").font(.headline).padding(.top)
            HStack { Text("현재 최고가").foregroundColor(.gray); Text("\(currentPrice.wonFormatted)").bold() }
            Divider()
            HStack(spacing: 10) { ForEach(quickBids, id: \.self) { amount in Button(action: { bidInput = "\(currentPrice + amount)" }) { Text("+\(amount.wonFormatted)").font(.caption).padding(8).background(Color.red.opacity(0.1)).foregroundColor(.red).cornerRadius(8) } } }
            HStack { TextField("직접 입력", text: $bidInput).keyboardType(.numberPad).padding().background(Color.gray.opacity(0.1)).cornerRadius(8); Text("원").foregroundColor(.gray) }.padding(.horizontal)
            Button(action: placeBidAction) { Text("입찰하기").font(.title3).bold().foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.red).cornerRadius(12) }.padding(.horizontal).padding(.bottom)
        }
        .presentationDetents([.medium])
        .alert("알림", isPresented: $showAlert) { Button("확인", role: .cancel) { } } message: { Text(alertMessage) }
    }
    
    func placeBidAction() {
        guard let amount = Int(bidInput) else { return }
        if amount <= currentPrice { alertMessage = "현재 최고가보다 높게 입력하세요!"; showAlert = true; return }
        guard let url = URL(string: "http://localhost:8080/auctions/bid") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"; request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        let body = ["auctionPostId": auctionId, "bidPrice": amount]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                if let http = response as? HTTPURLResponse, http.statusCode == 201 { isPresented = false; onBidSuccess() }
                else { alertMessage = "입찰 실패 (본인 경매이거나 에러 발생)"; showAlert = true }
            }
        }.resume()
    }
}
