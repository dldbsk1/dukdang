//
//  AuctionContentView.swift
//  Dukdang
//

import SwiftUI

// MARK: - 더미 데이터

extension Item {
    static let dummyAuction = Item(
        id: UUID(),
        title: "빈티지 필름 카메라",
        description: """
            오래된 필름 카메라입니다.
            상태 양호하며 실제 촬영 가능합니다.
            필름 1롤 포함해서 드립니다.
            """,
        price: 30000,
        likeCount: 14,
        status: "경매중",
        imageName: "logo",
        seller: SellerInfo(
            name: "필름덕후",
            profileImageName: "profile"
        ),
        postTime: "2분 전",
        category: .electronic,
        saleType: .auction,
        auctionEndTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(3600)),
        currentBidPrice: 35000,
        bidCount: 3
    )
}

// MARK: - 메인 뷰

struct AuctionContentView: View {
    let item: Item
    @State private var showBidSheet = false
    @State private var timeRemaining: String = ""
    @State private var currentBidPrice: Int
    @State private var bidCount: Int

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(item: Item) {
        self.item = item
        self._currentBidPrice = State(initialValue: item.currentBidPrice ?? item.price)
        self._bidCount = State(initialValue: item.bidCount ?? 0)
    }

    var isAuctionEnded: Bool {
        guard let endTimeStr = item.auctionEndTime else { return false }
        let formatter = ISO8601DateFormatter()
        guard let endDate = formatter.date(from: endTimeStr) else { return false }
        return endDate.timeIntervalSinceNow <= 0
    }

    var body: some View {
        VStack(spacing: 0) {

            // MARK: 상단 이미지
            ZStack(alignment: .topLeading) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipped()

                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    HStack(spacing: 16) {
                        Image(systemName: "house")
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.white)
                    .padding()
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {

                    // MARK: 프로필
                    HStack {
                        Image(item.seller.profileImageName)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))

                        VStack(alignment: .leading) {
                            Text(item.seller.name).font(.headline)
                        }
                    }

                    Divider()

                    // MARK: 상태 + 제목 + 시간
                    HStack {
                        Text(item.status)
                            .font(.caption)
                            .padding(6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                        Spacer()
                    }

                    HStack {
                        Text(item.title).font(.title3).bold()
                        Text("\(item.category.rawValue) · \(item.postTime)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // MARK: 설명
                    Text(item.description)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 10)
                        .font(.body)

                    Text("이 게시글 신고하기")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Divider()

                    // MARK: 경매 정보 박스
                    VStack(spacing: 12) {

                        // 시작가
                        HStack {
                            Text("시작가")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(item.price.wonFormatted)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Divider()

                        // 현재 최고 입찰가
                        HStack {
                            Text("현재 최고 입찰가")
                                .font(.title3)
                                .bold()
                            Spacer()
                            Text(currentBidPrice.wonFormatted)
                                .font(.title)
                                .bold()
                                .foregroundColor(.red)
                        }

                        // 입찰 횟수
                        HStack {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                            Text("총 \(bidCount)회 입찰")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                        }

                        Divider()

                        // 실시간 카운트다운 타이머 (오른쪽 정렬)
                        HStack {
                            Image(systemName: isAuctionEnded ? "flag.checkered" : "stopwatch")
                                .foregroundColor(isAuctionEnded ? .gray : .orange)
                            if isAuctionEnded {
                                Text("경매 종료")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Text(timeRemaining.isEmpty ? "계산 중..." : timeRemaining)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                            }
                        }
                        .onReceive(timer) { _ in
                            if let endTime = item.auctionEndTime {
                                self.timeRemaining = calculateTimeRemaining(until: endTime)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.07))
                    .cornerRadius(12)
                }
                .padding()
            }

            Divider()

            // MARK: 하단 바
            HStack {
                VStack(alignment: .center) {
                    Button(action: {}) {
                        Image(systemName: "heart").font(.title2)
                    }
                    Text("\(item.likeCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: { showBidSheet = true }) {
                    Text(isAuctionEnded ? "경매 종료" : "가격 올리기")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isAuctionEnded ? Color.gray : Color.blue)
                        .cornerRadius(8)
                }
                .disabled(isAuctionEnded)
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            if let endTime = item.auctionEndTime {
                self.timeRemaining = calculateTimeRemaining(until: endTime)
            }
        }
        .sheet(isPresented: $showBidSheet) {
            BidSheetView(
                currentPrice: $currentBidPrice,
                bidCount: $bidCount,
                isPresented: $showBidSheet
            )
        }
    }

    // MARK: 남은 시간 계산
    private func calculateTimeRemaining(until dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let endDate = formatter.date(from: dateString) else { return "" }

        let diff = Int(endDate.timeIntervalSinceNow)
        if diff <= 0 { return "경매 종료" }

        let days    = diff / 86400
        let hours   = (diff % 86400) / 3600
        let minutes = (diff % 3600) / 60
        let seconds = diff % 60

        if days > 0  { return "\(days)일 \(hours)시간 남음" }
        if hours > 0 { return "\(hours)시간 \(minutes)분 \(seconds)초 남음" }
        return "\(minutes)분 \(seconds)초 남음"
    }
}

// MARK: - 가격 올리기 바텀 시트

struct BidSheetView: View {
    @Binding var currentPrice: Int
    @Binding var bidCount: Int
    @Binding var isPresented: Bool
    @State private var bidInput: String = ""

    let quickBids = [100, 500, 1000, 5000]

    var body: some View {
        VStack(spacing: 20) {
            Text("가격 올리기")
                .font(.headline)
                .padding(.top)

            HStack {
                Text("현재 최고가").foregroundColor(.gray)
                Text(currentPrice.wonFormatted).bold()
            }

            Divider()

            HStack(spacing: 10) {
                ForEach(quickBids, id: \.self) { amount in
                    Button(action: {
                        bidInput = "\(currentPrice + amount)"
                    }) {
                        Text("+\(amount)원")
                            .font(.caption)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
            }

            HStack {
                TextField("직접 입력", text: $bidInput)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                Text("원").foregroundColor(.gray)
            }
            .padding(.horizontal)

            Button(action: {
                if let newPrice = Int(bidInput), newPrice > currentPrice {
                    currentPrice = newPrice
                    bidCount += 1
                }
                isPresented = false
            }) {
                Text("입찰하기")
                    .font(.title3).bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    NavigationStack {
        AuctionContentView(item: .dummyAuction)
    }
}
