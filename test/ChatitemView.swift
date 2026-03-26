import SwiftUI

// 메시지 모델
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isMe: Bool
    let time: String
    let isRead: Bool
}

// 🔹 상품 바
struct ProductBar: View {
    var body: some View {
        HStack(spacing: 10) {
            
            // 이미지
            Image(systemName: "photo")
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            // 상품명 + 가격
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("아이폰 13 프로")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text("상태 좋아요 / 배터리 90%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Text("850,000원")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

//메인 뷰
struct ChatitemView: View {
    
    @State private var message: String = ""
    @State private var messages: [Message] = []
    
    let color = Color(red: 0.75, green: 0.9, blue: 1.0)
    
    var body: some View {
        VStack(spacing: 0) {
            
            //상단 바
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                Text("닉네임")
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            Divider()
            
            // ✅ 상품 바 추가
            ProductBar()
            
            Divider()
            
            //채팅 영역
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 15) {
                        
                        Text("2026년 3월 17일")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ForEach(messages) { msg in
                            ChatBubble(message: msg, color: color)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) {
                    if let last = messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // 입력 영역
            HStack(spacing: 10) {
                
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                
                TextField("메시지를 입력하세요", text: $message)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Text("전송")
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(color)
                        .cornerRadius(15)
                }
            }
            .padding()
        }
    }
    
    // 메시지 전송
    func sendMessage() {
        if !message.isEmpty {
            let new = Message(
                text: message,
                isMe: true,
                time: currentTime(),
                isRead: false
            )
            messages.append(new)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                if let lastIndex = messages.indices.last {
                    messages[lastIndex] = Message(
                        text: messages[lastIndex].text,
                        isMe: true,
                        time: messages[lastIndex].time,
                        isRead: true
                    )
                }
                
                let reply = Message(
                    text: "네! 확인했습니다 😊",
                    isMe: false,
                    time: currentTime(),
                    isRead: true
                )
                
                messages.append(reply)
            }
            
            message = ""
        }
    }
    
    func currentTime() -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: Date())
    }
}

// 채팅 버블
struct ChatBubble: View {
    
    let message: Message
    let color: Color
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            
            if message.isMe {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    if message.isRead {
                        Text("읽음")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    
                    Text(message.time)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                bubble
                
            } else {
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.gray)
                
                bubble
                
                Text(message.time)
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
    
    var bubble: some View {
        Text(message.text)
            .padding(10)
            .background(message.isMe ? color : Color.gray.opacity(0.2))
            .clipShape(BubbleShape(isMe: message.isMe))
    }
}

// 말풍선 꼬리
struct BubbleShape: Shape {
    var isMe: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = RoundedRectangle(cornerRadius: 12).path(in: rect)
        
        let tailSize: CGFloat = 6
        
        if isMe {
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - 10))
            path.addLine(to: CGPoint(x: rect.maxX + tailSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX - 2, y: rect.maxY))
        } else {
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY - 10))
            path.addLine(to: CGPoint(x: rect.minX - tailSize, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX + 2, y: rect.maxY))
        }
        
        return path
    }
}

#Preview {
    ChatitemView()
}
