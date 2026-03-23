// 거래홈 (민진)
//  MainView.swift
//  Dukdang
//
//  Created by mac16 on 3/16/26.
//

import SwiftUI

// 게시물 데이터 구조체
struct Product: Identifiable {
    let id = UUID()
    let title: String
    let price: String   // 원가
    let newPrice: String    // AI가 재설정한 가격
    let time: String
    let heartCount: Int
    let imageName: String // 실제 이미지가 있다면 이미지 이름
}

struct MainView: View {
    @State private var showActionSheet = false
    @State private var isGoUpload = false
    @State private var isGoAuction = false
    @State private var isGoMyPage = false
    
    @State private var selectedCategory: String = "전체"
    private let categories: [String] = ["전체","학습교재","디지털기기", "생활용품", "의류", "기타"]

    // 5개 게시물 데이터 배열
    let products = [
            Product(title: "C언어 프로그래밍", price: "15,000원", newPrice: "12,000원", time: "1분 전", heartCount: 5, imageName: "book.closed"),
            Product(title: "아이패드 에어 5세대", price: "550,000원", newPrice: "510,000원", time: "5분 전", heartCount: 12, imageName: "ipad"),
            Product(title: "의자 2개 세트", price: "30,000원", newPrice: "25,000원", time: "15분 전", heartCount: 3, imageName: "chair.lounge"),
            Product(title: "나이키 운동화 270 (미개봉)", price: "89,000원", newPrice: "75,000원", time: "30분 전", heartCount: 8, imageName: "shoe"),
            Product(title: "맥북 프로 M2 14인치", price: "1,800,000원", newPrice: "1,650,000원", time: "5시간 전", heartCount: 25, imageName: "laptopcomputer")
        ]

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

                    // 3. List에서 배열 데이터를 하나씩 꺼내서 표시
                    List(products) { product in
                        ProductRow(product: product) // 데이터를 Row에 넘겨줌
                    }
                    .listStyle(.plain)
                    
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
            .confirmationDialog("상품 등록 종류", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("일반거래") { isGoUpload = true }
                Button("경매") { isGoAuction = true }
                Button("취소", role: .cancel) { }
            } message: {
                Text("원하시는 거래 방식을 선택해주세요.")
            }
        }
    }
}

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// ProductRow
struct ProductRow: View {
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: product.imageName)
                        .font(.largeTitle)
                        .foregroundColor(.gray.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text(product.title)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(1)
                
                Text("#쌍문동 • \(product.time)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                // 가격 영역: 줄 그어진 원가 + 새 가격
                HStack(spacing: 8) {
                    Text(product.price)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .strikethrough(true, color: .gray) // 원가 가로줄
                    
                    Text(product.newPrice)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.cyan)        // AI 재설정 가격
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
