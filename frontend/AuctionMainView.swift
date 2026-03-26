//
//  AuctionMainView.swift
//  Dukdang
//
//  Created by mac16 on 3/19/26.
//

import SwiftUI

// 1. 경매 게시물용 데이터 모델
struct AuctionItem: Identifiable {
    let id = UUID()
    let title: String
    let startPrice: String
    let time: String
    let heartCount: Int
    let imageName: String
}

struct AuctionMainView: View {
    // 화면 이동 및 액션 시트 상태 변수
    @State private var showActionSheet = false
    @State private var isGoUpload = false      // 일반거래
    @State private var isGoAuction = false     // 경매
    
    // 카테고리 설정
    @State private var selectedCategory: String = "전체"
    private let categories: [String] = ["전체","학습교재","디지털기기", "생활용품", "의류", "기타"]
    
    // 경매 샘플 데이터
    let auctionItems = [
        AuctionItem(title: "빈티지 필름 카메라", startPrice: "30,000원", time: "2분 전", heartCount: 14, imageName: "camera.fill"),
        AuctionItem(title: "서울대생 애완 돌멩이", startPrice: "18,000원", time: "25분 전", heartCount: 6, imageName: "seal.fill"),
        AuctionItem(title: "반질반질 윤이 나는 당근", startPrice: "5,000원", time: "12분 전", heartCount: 48, imageName: "carrot.fill"),
        AuctionItem(title: "국내대회 1등한 베이스 기타", startPrice: "200,000원", time: "1시간 전", heartCount: 42, imageName: "guitars.fill"),
        AuctionItem(title: "전설의 포켓몬 '뮤' 띠부씰", startPrice: "50,000원", time: "3시간 전", heartCount: 9, imageName: "sparkles")
    ]
    
    var body: some View {
        ZStack {
            // 숨겨진 네비게이션 링크들 (MainView와 동일)
            NavigationLink(destination: AddView(), isActive: $isGoUpload) { EmptyView() }.hidden()
            NavigationLink(destination: AuctionAddView(), isActive: $isGoAuction) { EmptyView() }.hidden()
            
            VStack(spacing: 0) {
                // 상단 카테고리 메뉴
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

                // 리스트 출력
                List(auctionItems) { item in
                    AuctionRow(item: item)
                }
                .listStyle(.plain)
            }

            // 빨간색 플러스 버튼
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showActionSheet = true // 플러스 버튼 누르면 메뉴 띄움
                    }) {
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
        // 플러스 버튼 클릭 시 메뉴 로직
        .confirmationDialog("상품 등록 종류", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("일반거래") { isGoUpload = true }
            Button("경매") { isGoAuction = true }
            Button("취소", role: .cancel) { }
        } message: {
            Text("원하시는 거래 방식을 선택해주세요.")
        }
    }
}

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// AuctionRow
struct AuctionRow: View {
    let item: AuctionItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.05))  // 이미지 바탕 색상
                .frame(width: 100, height: 100)
                .overlay(Image(systemName: item.imageName).font(.largeTitle).foregroundColor(.red.opacity(0.4))) //이미지 아이콘 색상
            
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                
                Text("#쌍문동 • \(item.time)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                // 가격
                HStack(spacing: 4) {
                    Text("시작가")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                    Text(item.startPrice)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.red)
                }
                .padding(.top, 2)
                
                Spacer(minLength: 0)
                
                HStack {
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "heart").font(.system(size: 12))
                        Text("\(item.heartCount)").font(.system(size: 13))
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
    NavigationStack {
        AuctionMainView()
    }
}
