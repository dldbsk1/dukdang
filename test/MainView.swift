//
//  MainView.swift
//  test
//
//  Created by mac00 on 3/25/26.
//

import SwiftUI

struct MainView: View {
    @State private var showActionSheet = false
    @State private var isGoUpload = false
    @State private var isGoAuction = false
    @State private var isGoMyPage = false
    
    @State private var selectedCategory: String = "전체"
    private let categories: [String] = ["전체","전공서적","전자기기","생활용품","자취/가구","의류/잡화","식품/간식","티켓/양도","과제/자료","기타"]

    @State private var products: [TradePostItem] = []

    var body: some View {
        NavigationStack {
            ZStack {
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

                    // 게시물 리스트
                    List(products) { item in
                        // 일반 거래와 경매 상세 뷰 분기 처리필요
                        NavigationLink(destination: AuctionContentView(item: item.toItem())) {
                            ProductRow(item: item)
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { fetchPosts() }
                }

                // 플러스 플로팅 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showActionSheet = true }) {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(25)
                    }
                }
            }
            // 액션 시트 (플러스 버튼 클릭 시)
            .confirmationDialog("글쓰기", isPresented: $showActionSheet) {
                Button("일반 거래 등록") { isGoUpload = true }
                Button("경매 등록") { isGoAuction = true }
                Button("취소", role: .cancel) {}
            }
            .navigationDestination(isPresented: $isGoUpload) { AddView() }
            .navigationDestination(isPresented: $isGoAuction) { AuctionAddView() }
            .navigationDestination(isPresented: $isGoMyPage) {
                UserProfileView(sellerNickname: "본인", items: products, isMyProfile: true)
            }
            .onAppear {
                if products.isEmpty { loadDummyData() }
                fetchPosts()
            }
        }
    }

    func loadDummyData() {
        let now = Date()
        let formatter = ISO8601DateFormatter()
        
        let t1 = Calendar.current.date(byAdding: .minute, value: -1, to: now)!
        let t2 = Calendar.current.date(byAdding: .minute, value: -5, to: now)!
        let t3 = Calendar.current.date(byAdding: .minute, value: -15, to: now)!
        let t4 = Calendar.current.date(byAdding: .minute, value: -30, to: now)!
        let t5 = Calendar.current.date(byAdding: .hour, value: -5, to: now)!

        self.products = [
            TradePostItem(id: 1, title: "C언어 프로그래밍", price: 12000, category: "전공서적", status: "RESERVED", imageUrl: nil, sellerNickname: "공대생", viewCount: 10, wishCount: 5, postTime: formatter.string(from: t1), endTime: nil),
            TradePostItem(id: 2, title: "아이패드 에어 5세대", price: 510000, category: "전자기기", status: "SALE", imageUrl: nil, sellerNickname: "애플유저", viewCount: 45, wishCount: 12, postTime: formatter.string(from: t2), endTime: nil),
            TradePostItem(id: 3, title: "의자 2개 세트", price: 25000, category: "생활용품", status: "SALE", imageUrl: nil, sellerNickname: "자취생", viewCount: 15, wishCount: 3, postTime: formatter.string(from: t3), endTime: nil),
            TradePostItem(id: 4, title: "나이키 운동화 270 (미개봉)", price: 75000, category: "의류/잡화", status: "RESERVED", imageUrl: nil, sellerNickname: "슈즈홀릭", viewCount: 32, wishCount: 8, postTime: formatter.string(from: t4), endTime: nil),
            TradePostItem(id: 5, title: "맥북 프로 M2 14인치", price: 1650000, category: "전자기기", status: "SOLD", imageUrl: nil, sellerNickname: "맥북유저", viewCount: 120, wishCount: 25, postTime: formatter.string(from: t5), endTime: nil)
        ]
    }

    func fetchPosts() { /* 서버 통신 로직 */ }
}
// MARK: - ProductRow
struct ProductRow: View {
    let item: TradePostItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ZStack(alignment: .topLeading) {
                // 이미지 영역
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray.opacity(0.5)))
                
                // 뱃지 전용 함수 호출
                badgeView(for: item.status)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title).font(.system(size: 16, weight: .medium)).lineLimit(1)
                
                Text(relativeTimeString(from: item.postTime))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text("\(item.price)원")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.blue)
                
                Spacer(minLength: 0)
                
                HStack {
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
    }
    
    // 뱃지 생성을 담당하는 ViewBuilder 함수
    @ViewBuilder
    private func badgeView(for statusString: String) -> some View {
        if let status = TradeStatus(rawValue: statusString), status != .SALE {
            // SALE이 아닐 때만 변수를 할당하고 텍스트를 그립니다.
            let badgeInfo: (text: String, color: Color) = {
                switch status {
                case .RESERVED:
                    return ("예약중", .blue)
                case .SOLD:
                    return ("거래완료", .gray)
                default:
                    return ("", .clear)
                }
            }()
            
            Text(badgeInfo.text)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(badgeInfo.color)
                .cornerRadius(4)
                .padding(5)
        }
        // status가 SALE인 경우 아무것도 반환하지 않음 (EmptyView)
    }
    
    func relativeTimeString(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "방금 전" }
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        if let day = components.day, day > 0 { return "\(day)일 전" }
        if let hour = components.hour, hour > 0 { return "\(hour)시간 전" }
        if let minute = components.minute, minute > 0 { return "\(minute)분 전" }
        return "방금 전"
    }
}
#Preview {
    MainView()
}
