import SwiftUI

struct TabBarView: View {
    // 현재 선택된 탭을 기억하는 변수 (기본값 0 = 홈)
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // 1. 메인 화면 (일반 거래)
            MainView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }
                .tag(0)
            
            // 2. 경매 화면
            AuctionMainView()
                .tabItem {
                    Image(systemName: "wonsign.circle.fill")
                    Text("경매")
                }
                .tag(1)
            
            // 3. 위시리스트 (좋아요)
            WishlistView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("좋아요")
                }
                .tag(2)
            
            // 4. 채팅 목록
            ChatlistView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("채팅")
                }
                .tag(3)
        }
        // 💡 선택된 탭의 포인트 컬러 (청록색)
        .tint(.cyan)
    }
}

#Preview {
    TabBarView()
}
