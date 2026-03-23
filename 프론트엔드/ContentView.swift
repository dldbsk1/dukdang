import SwiftUI

// MARK: - 데이터 모델

struct TradeItem: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: String
    let price: Int
    let isPriceNegotiable: Bool  // 가격제안 가능 여부
    let likeCount: Int
    let postedAt: String
    let status: String
    let imageName: String        // Assets 이미지 이름
    let seller: TradeSellerInfo
    let petCategory: String?     // 반려동물 관련 문구 (없으면 nil)
}

struct TradeSellerInfo {
    let name: String
    let location: String
    let profileImageName: String  // Assets 이미지 이름
    let temperature: Double
}

// MARK: - 더미 데이터 (나중에 API 응답으로 교체)

extension TradeItem {
    static let dummy = TradeItem(
        id: UUID(),
        title: "강아지 넥카라",
        description: """
            구매할 때 10000원 정도 주고 구매했고,
            5번 정도 사용한 제품입니다.
            넥카라 깔끔하게 사용해서 거의 새 물건 상태입니다!
            """,
        category: "반려동물용품",
        price: 5000,
        isPriceNegotiable: true,
        likeCount: 56,
        postedAt: "1초 전",
        status: "판매중",
        imageName: "logo",
        seller: TradeSellerInfo(
            name: "무니엄",
            location: "논현동",
            profileImageName: "profile",
            temperature: 36.8
        ),
        petCategory: "반려동물 관련 상품이에요 🐕"
    )
}

// MARK: - 메인 뷰

struct ContentView: View {
    // 💡 1. 채팅 화면 이동을 위한 상태 변수 추가
    @State private var isGoChat = false    // 화면을 닫기 위한 환경 변수
    @Environment(\.dismiss) private var dismiss
    
    // 나중에 ViewModel 또는 API에서 주입
    let item: TradeItem

    var body: some View {
        VStack(spacing: 0) {
            
            // 💡 2. 채팅 화면으로 넘겨줄 내비게이션 링크 (숨김 처리)
            NavigationLink(destination: ChatitemView(), isActive: $isGoChat) {
                            EmptyView()
                        }
                        .hidden()
            // 상단 이미지
            ZStack(alignment: .topLeading) {
                // 💡 웹 이미지(http)와 앱 내부 이미지 모두 처리할 수 있도록 수정
                if item.imageName.hasPrefix("http") {
                    AsyncImage(url: URL(string: item.imageName)) { image in
                        image.resizable()
                             .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 300)
                    .clipped()
                } else {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipped()
                }
                
                // 💡 상단 버튼 모음 (노치 영역을 피해서 아래로 내리고, 검은색 반투명 배경 추가!)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4)) // 반투명 배경
                            .clipShape(Circle())
                    }
                    Spacer()
                    
                    HStack(spacing: 12) {
                        Image(systemName: "house")
                            .font(.system(size: 18, weight: .bold))
                            .padding(10)
                            .background(Color.black.opacity(0.4)) // 반투명 배경
                            .clipShape(Circle())
                        
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .padding(10)
                            .background(Color.black.opacity(0.4)) // 반투명 배경
                            .clipShape(Circle())
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 55) // 💡 노치(상단 상태바) 영역만큼 아래로 밀어줍니다.
            }
            
            // 본문
            VStack(alignment: .leading, spacing: 12) {
                
                // 프로필 + 온도
                HStack {
                    Image(item.seller.profileImageName)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading) {
                        Text(item.seller.name)
                            .font(.headline)
                        Text(item.seller.location)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(item.seller.temperature, specifier: "%.1f")°C")
                            .foregroundColor(.blue)
                            .bold()
                        Text("매너온도")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Divider()
                
                // 상태
                HStack {
                    Text(item.status)
                        .font(.caption)
                        .padding(6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    Spacer()
                }
                
                HStack {
                    Text(item.title)
                        .font(.title3)
                        .bold()
                    
                    Text("\(item.category) · \(item.postedAt)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                // 설명
                Text(item.description)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
                    .font(.body)
                
                Text("이 게시글 신고하기")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                // 반려동물 관련 문구 (있을 때만 표시)
                if let petCategory = item.petCategory {
                    HStack {
                        Spacer()
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.orange)
                        Text(petCategory)
                            .font(.caption)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
            
            Divider()
            
            // 하단 바
            HStack {
                VStack(alignment: .center) {
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.title2)
                    }
                    Text("\(item.likeCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading) {
                    Text("가격")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(item.price.wonFormatted)
                        .font(.title2)
                        .bold()
                }
                
                Spacer()
                
                // 💡 3. '채팅 하기' 버튼 액션 수정
                Button(action: {
                        isGoChat = true // 버튼 누르면 변수를 true로 바꿔서 화면 이동
                                }) {
                        Text("채팅 하기")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(Color.blue)
                            .cornerRadius(8)
                                }
                            }            .padding()
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 숨김
    }
}

// MARK: - Int 확장 (숫자 포맷팅)
extension Int {
    var wonFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // 3자리마다 콤마(,) 추가
        
        if let formattedNumber = formatter.string(from: NSNumber(value: self)) {
            return "\(formattedNumber)원"
        }
        return "\(self)원"
    }
}

// MARK: - 프리뷰
#Preview {
    ContentView(item: .dummy)
}
