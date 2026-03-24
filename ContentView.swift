//
//  ContentView.swift
//  Dukdang
//
//  Created by mac16 on 3/16/26.
//

import SwiftUI

struct ContentView: View {
    // MainView에서 넘겨주는 동일한 데이터 모델 사용
    let item: TradePostItem

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 1. 상단 이미지 영역
                    ZStack(alignment: .topLeading) {
                        if let urlStr = item.imageUrl, let url = URL(string: urlStr) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.1))
                            }
                            .frame(height: 300)
                            .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 300)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray.opacity(0.5))
                                )
                        }
                    }

                    // 2. 판매자 정보 (프로필)
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill") // 실제 데이터에 프로필이 없으므로 기본 아이콘
                            .resizable()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.sellerNickname)
                                .font(.headline)
                            Text("서울 특별시") // 위치 정보가 없으므로 기본값 또는 생략
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("36.5°C") // 매너온도 데이터가 없을 시 기본값
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("매너온도")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()

                    Divider()

                    // 3. 상품 본문 내용
                    VStack(alignment: .leading, spacing: 12) {
                        // 상태 표시 (SALE 아닐 때만 노출)
                        if let status = TradeStatus(rawValue: item.status), status != .SALE {
                            Text(status == .RESERVED ? "예약중" : "거래완료")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(status == .RESERVED ? Color.orange : Color.gray)
                                .cornerRadius(4)
                        }

                        Text(item.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("\(item.category) • \(relativeTimeString(from: item.postTime))")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // 상세 설명 (TradePostItem에 description이 없다면 제목이나 더미 사용)
                        Text("상품 상세 설명이 들어가는 자리입니다. 실제 데이터 모델에 description 필드가 있다면 해당 내용을 출력합니다.")
                            .font(.body)
                            .padding(.top, 8)
                            .lineSpacing(4)

                        Text("조회 \(item.viewCount) • 관심 \(item.wishCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                    }
                    .padding()
                }
            }

            Divider()

            // 4. 하단 바 (가격 및 채팅하기)
            HStack(spacing: 20) {
                Button(action: { /* 찜 로직 */ }) {
                    VStack(spacing: 4) {
                        Image(systemName: "heart")
                            .font(.title3)
                        Text("\(item.wishCount)")
                            .font(.caption2)
                    }
                    .foregroundColor(.gray)
                }

                Divider()
                    .frame(height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(item.price)원")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("가격 제안 불가") // 필요 시 로직 추가
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: { /* 채팅 시작 */ }) {
                    Text("채팅하기")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(UIColor.systemBackground))
        }
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.top)
    }

    // 시간 변환 함수 (MainView와 동일하게 유지)
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

// MARK: - 프리뷰 (TradePostItem 기반)
#Preview {
    ContentView(item: TradePostItem(
        id: 1,
        title: "아이폰 15 프로",
        price: 1200000,
        category: "디지털기기",
        status: "SALE",
        imageUrl: nil,
        sellerNickname: "애플매니아",
        viewCount: 150,
        wishCount: 12,
        postTime: "2026-03-24T10:00:00Z",
        endTime: nil
    ))
}
