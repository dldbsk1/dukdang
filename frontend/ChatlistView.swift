import SwiftUI

struct ChatlistView: View {
    // 💡 새로운 모델 이름 적용
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
                                // 💡 클릭 시 상세 채팅방으로 이동
                                NavigationLink(destination: ChatitemView(
                                    roomId: room.roomId,
                                    productTitle: room.tradePostTitle,
                                    productPrice: "",
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
            // ... 하단바 및 fullScreenCover 생략 (기존과 동일) ...
        }
    }
    
    func fetchChatRooms() {
        // 💡 백엔드 ChatRestController의 경로와 맞춤
        guard let url = URL(string: "http://localhost:8080/api/chat/rooms") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                // 💡 SimpleAPIResponse 구조에 맞춰 파싱
                do {
                    let decoded = try JSONDecoder().decode(SimpleAPIResponse<[ChatRoomListResponse]>.self, from: data)
                    if let rooms = decoded.data {
                        DispatchQueue.main.async {
                            self.chatRooms = rooms
                        }
                    }
                } catch {
                    print("❌ 채팅 목록 파싱 에러: \(error)")
                }
            }
        }.resume()
    }
}

struct ChatRoomRow: View {
    let room: ChatRoomListResponse // 💡 모델명 변경 적용
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(Color.gray.opacity(0.3)).frame(width: 50, height: 50)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(room.otherUserNickname).font(.system(size: 16, weight: .bold))
                Text(room.lastMessage.isEmpty ? "대화 내용이 없습니다." : room.lastMessage)
                    .font(.system(size: 14)).foregroundColor(.gray).lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                // 시간 표시 (예: "2026-03-24T00:09..."에서 시간만 추출)
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
