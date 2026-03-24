import SwiftUI

// MARK: - 1. 데이터 모델
struct ChatMessageResponse: Codable, Identifiable {
    let id: Int
    let roomId: Int
    let senderId: Int
    let senderNickname: String
    let content: String
    let read: Bool
    let postTime: String
    // UI에서 기존의 isRead 이름을 계속 쓰고 싶다면 아래처럼 계산된 속성을 추가해도 됩니다.
    var isRead: Bool { read }
}

struct SimpleAPIResponse<T: Codable>: Codable {
    let status: Int?
    let message: String?
    let data: T?
}

// MARK: - 2. 서브 컴포넌트
struct ProductBar: View {
    let title: String
    let price: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 45)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .medium)).lineLimit(1)
                Text(price).font(.system(size: 15, weight: .bold))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
    }
}

// MARK: - 3. 메인 채팅 뷰
struct ChatitemView: View {
    let roomId: Int
    let productTitle: String
    let productPrice: String
    let sellerId: Int // 💡 새로 추가됨: 상품의 판매자 ID
    
    @StateObject private var socketManager = ChatWebSocketManager()
    @State private var messageText: String = ""
    @State private var messages: [ChatMessageResponse] = []
    @AppStorage("myUserId") var myUserId: Int = 0
    // 💡 테스트를 위해 현재 로그인한 내 ID를 1로 가정 (나중에 UserDefaults에서 불러와야 함)
    
    let color = Color(red: 0.75, green: 0.9, blue: 1.0)
    
    var body: some View {
        VStack(spacing: 0) {
            HStack { Text("채팅방").font(.headline); Spacer() }.padding()
            Divider()
            ProductBar(title: productTitle, price: productPrice)
            Divider()
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(messages) { msg in
                                                    // 💡 내 ID와 메시지 보낸 사람 ID를 실시간 비교!
                                                    ChatBubble(message: msg, isMe: msg.senderId == myUserId, color: color)
                                                        .id(msg.id)
                                                }                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }
            Divider()
            
            HStack(spacing: 10) {
                TextField("메시지를 입력하세요", text: $messageText)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                
                Button(action: sendMessageToServer) {
                    Text("전송")
                        .fontWeight(.bold)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(messageText.isEmpty ? Color.gray.opacity(0.3) : color)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
        }
        .onAppear {
            fetchChatHistory()
            socketManager.connect(roomId: roomId)
        }
        .onDisappear {
            // 💡 [에러 해결] $ 기호 제거!
            socketManager.disconnect()
        }
        .onReceive(socketManager.$receivedMessage) { newMessage in
            if let msg = newMessage { self.messages.append(msg) }
        }
    }
    
    // 💡 중복 선언된 함수 정리 및 소켓 전송 활성화
    func sendMessageToServer() {
        if messageText.isEmpty { return }
        // 💡 소켓 매니저를 통해 실제 서버로 메시지 전송
        socketManager.sendMessage(content: messageText)
        messageText = ""
    }
    
    func fetchChatHistory() {
        guard let url = URL(string: "http://localhost:8080/chat/rooms/\(roomId)/messages") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                // 💡 [디버깅 추가] 서버가 준 과거 내역 데이터를 통째로 출력해봅니다.
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("📥 과거 내역 응답: \(jsonString)")
                }
                
                do {
                    let decoded = try JSONDecoder().decode(SimpleAPIResponse<[ChatMessageResponse]>.self, from: data)
                    if let history = decoded.data {
                        DispatchQueue.main.async { self.messages = history }
                    }
                } catch {
                    // 💡 [디버깅 추가] 파싱에 실패하면 왜 실패했는지 에러를 찍어줍니다.
                    print("❌ 과거 내역 파싱 에러: \(error)")
                }
            }
        }.resume()
    }
}

// MARK: - 4. UI 구성 요소
struct ChatBubble: View {
    let message: ChatMessageResponse
    let isMe: Bool
    let color: Color
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            if isMe {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    if message.isRead { Text("읽음").font(.caption2).foregroundColor(.gray) }
                    Text(message.postTime.suffix(8).prefix(5)).font(.caption2).foregroundColor(.gray)
                }
                Text(message.content).padding(10).background(color).clipShape(BubbleShape(isMe: true))
            } else {
                Image(systemName: "person.circle.fill").resizable().frame(width: 30, height: 30).foregroundColor(.gray)
                Text(message.content).padding(10).background(Color.gray.opacity(0.2)).clipShape(BubbleShape(isMe: false))
                Text(message.postTime.suffix(8).prefix(5)).font(.caption2).foregroundColor(.gray)
                Spacer()
            }
        }
    }
}

struct BubbleShape: Shape {
    var isMe: Bool
    func path(in rect: CGRect) -> Path { RoundedRectangle(cornerRadius: 12).path(in: rect) }
}

// 프리뷰
#Preview {
    ChatitemView(roomId: 1, productTitle: "테스트 상품", productPrice: "10,000원", sellerId: 1)
}
