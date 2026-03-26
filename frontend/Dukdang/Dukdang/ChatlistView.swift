import SwiftUI

struct ChatlistView: View {
    @State private var chatRooms: [ChatRoomListResponse] = []
    @State private var goToWishlist = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider().padding(.top, 10)
                
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if chatRooms.isEmpty {
                            Text("참여 중인 채팅방이 없습니다.")
                                .foregroundColor(.gray)
                                .padding(.top, 50)
                        } else {
                            ForEach(chatRooms) { room in
                                NavigationLink(destination: ChatitemView(
                                    roomId: room.roomId,
                                    productTitle: room.tradePostTitle,
                                    productPrice: "",
                                    productImageUrl: room.tradePostImageUrl, // 💡 [추가됨] 상품 사진 넘겨주기!
                                    sellerId: room.otherUserId
                                )) {
                                    ChatRoomRow(room: room)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("채팅").font(.system(size: 32, weight: .bold))
                }
            }
            .onAppear {
                fetchChatRooms()
            }
        }
    }
    
    func fetchChatRooms() {
        guard let url = URL(string: "http://localhost:8080/api/chat/rooms") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(SimpleAPIResponse<[ChatRoomListResponse]>.self, from: data)
                    if let rooms = decoded.data {
                        DispatchQueue.main.async { self.chatRooms = rooms }
                    }
                } catch {
                    print("❌ 채팅 목록 파싱 에러: \(error)")
                }
            }
        }.resume()
    }
}

struct ChatRoomRow: View {
    let room: ChatRoomListResponse
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 💡 [핵심 수정] 회색 동그라미 대신 진짜 프로필 사진을 띄웁니다!
            if let profileUrl = room.otherUserProfileImage, profileUrl.hasPrefix("http") {
                AsyncImage(url: URL(string: profileUrl)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                // 프사가 없을 때 기본 아이콘
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(room.otherUserNickname).font(.system(size: 16, weight: .bold))
                Text(room.lastMessage.isEmpty ? "대화 내용이 없습니다." : room.lastMessage)
                    .font(.system(size: 14)).foregroundColor(.gray).lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(room.lastMessageAt.suffix(8).prefix(5))
                    .font(.system(size: 12)).foregroundColor(.gray)
                
                if room.unreadCount > 0 {
                    Text("\(room.unreadCount)")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                        .frame(width: 20, height: 20).background(Color.red).clipShape(Circle())
                }
            }
        }
        .padding(.horizontal)
    }
}
