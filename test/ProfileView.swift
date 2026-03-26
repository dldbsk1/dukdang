import SwiftUI

struct UserProfileView: View {
    // 프로젝트 공통 모델 사용
    let sellerNickname: String
    let items: [TradePostItem]
    let isMyProfile: Bool

    @Environment(\.dismiss) var dismiss
    @State private var showEditProfile = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // 1. 프로필 섹션
                    profileSection

                    Divider().padding(.vertical, 8)

                    // 2. 판매 물품 목록
                    itemListSection
                }
            }
            .navigationTitle(isMyProfile ? "내 프로필" : "\(sellerNickname)님의 프로필")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
                
                if isMyProfile {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("수정") { showEditProfile = true }
                    }
                }
            }
        }
    }

    // MARK: - 프로필 섹션 영역
    private var profileSection: some View {
        VStack(spacing: 16) {
            // 프로필 이미지 (기본 아이콘 활용)
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.5))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))

            VStack(spacing: 4) {
                Text(sellerNickname)
                    .font(.title3)
                    .bold()
            }
            .padding(.top, 4)

            if isMyProfile {
                Button(action: { showEditProfile = true }) {
                    Text("프로필 수정")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                }
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
    }

    // MARK: - 판매 물품 리스트 영역
    private var itemListSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("판매 상품 (\(items.count))")
                .font(.headline)
                .padding(.horizontal)
                .padding(.bottom, 12)

            ForEach(items) { item in
                // 클릭 시 해당 상품의 ContentView(상세페이지)로 이동
                NavigationLink(destination: ContentView(item: item.toItem())) {
                    HStack(spacing: 12) {
                        // 이미지 영역
                        if let urlStr = item.imageUrl, let url = URL(string: urlStr) {
                            AsyncImage(url: url) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.1)
                            }
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                            .clipped()
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 70, height: 70)
                                .overlay(Image(systemName: "photo").foregroundColor(.gray.opacity(0.4)))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Text("\(item.price)원")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(relativeTimeString(from: item.postTime))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // 상태 표시 뱃지
                        if let status = TradeStatus(rawValue: item.status) {
                            Text(status == .SALE ? "판매중" : (status == .RESERVED ? "예약중" : "완료"))
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(status == .SALE ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .foregroundColor(status == .SALE ? .blue : .gray)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                Divider().padding(.leading, 98)
            }
        }
        .padding(.vertical, 8)
    }

    // 공통 시간 변환 함수
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

// MARK: - 프리뷰
#Preview {
    UserProfileView(
        sellerNickname: "무니엄",
        items: [
            TradePostItem(id: 1, title: "강아지 넥카라", price: 5000, category: "반려동물", status: "SALE", imageUrl: nil, sellerNickname: "무니엄", viewCount: 10, wishCount: 2, postTime: "2026-03-24T13:00:00Z", endTime: nil),
            TradePostItem(id: 2, title: "펫 이동장", price: 25000, category: "반려동물", status: "SOLD", imageUrl: nil, sellerNickname: "무니엄", viewCount: 50, wishCount: 8, postTime: "2026-03-22T10:00:00Z",endTime: nil)
        ],
        isMyProfile: false
    )
}
