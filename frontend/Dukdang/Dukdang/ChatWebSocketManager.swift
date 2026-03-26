import Foundation
import SwiftStomp

class ChatWebSocketManager: ObservableObject {
    @Published var receivedMessage: ChatMessageResponse? = nil
    private var client: SwiftStomp?
    private var roomId: Int?

    func connect(roomId: Int) {
        self.roomId = roomId
        
        // 백엔드 WebSocketConfig.java 설정 주소
        let url = URL(string: "ws://localhost:8080/ws-chat/websocket")!
        
        // WebSocketSecurityConfig.java에서 요구하는 Bearer 토큰 인증
        var headers = [String: String]()
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        client = SwiftStomp(host: url, headers: headers)
        client?.delegate = self
        client?.connect()
    }

    func sendMessage(content: String) {
        guard let roomId = self.roomId else { return }
        
        // 💡 백엔드의 ChatMessageRequestDto.java 필드명과 완벽히 똑같아야 합니다!
                let body: [String: Any] = ["roomId": roomId, "content": content]
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: body),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    
                    // 💡 [핵심 디버깅] 서버로 메시지를 쏘기 직전에 로그를 찍습니다.
                    print("🚀 [STOMP 발송] 경로: /pub/chat/message, 내용: \(jsonString)")
                    
                    // 💡 [해결] 헤더에 "content-type": "application/json"을 추가해서 보냅니다!
                    let headers = ["content-type": "application/json"]
                    client?.send(body: jsonString, to: "/pub/chat/message", headers: headers)                }
                else {
                    print("❌ JSON 변환 에러")
                }
            }
    func disconnect() {
        client?.disconnect()
    }
} // ⬅️ 클래스를 닫는 중괄호를 안전하게 분리했습니다!

// MARK: - Delegate Extension
// MARK: - Delegate Extension
extension ChatWebSocketManager: SwiftStompDelegate {
    
    // 1. 연결 성공
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        guard let roomId = self.roomId else { return }
        print("✅ 실시간 채팅 연결 성공 - 방 번호: \(roomId)")
        swiftStomp.subscribe(to: "/sub/chat/room/\(roomId)")
    }
    
    // 2. 연결 종료
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        print("🔌 연결 종료: \(disconnectType)")
    }
    
    // 3. 메시지 수신 (디버깅 강화 버전)
        func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
            
            // 💡 [핵심 디버깅] 서버가 쏴준 메시지 원본을 그대로 출력해봅니다!
            print("📨 [STOMP 수신] 내용: \(message ?? "내용 없음")")
            
            if let text = message as? String,
               let data = text.data(using: .utf8) {
                
                do {
                    // 백엔드 구조(ChatMessageResponse)와 일치하는지 해독 시도
                    let decoded = try JSONDecoder().decode(ChatMessageResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.receivedMessage = decoded
                    }
                    print("✅ 말풍선 그리기 성공!")
                } catch {
                    // 💡 [에러 확인] 여기서 에러가 난다면 변수명이나 타입이 미세하게 다른 겁니다.
                    print("❌ 실시간 메시지 파싱 에러: \(error)")
                }
            }
        }
    // 4. 영수증 수신
    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        print("🧾 영수증: \(receiptId)")
    }
    
    // 5. 에러 발생 (💡 해결: 1.2.1 버전에 맞게 매개변수 완전 교체)
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        print("❌ STOMP 에러: \(briefDescription)")
    }
    
    // 6. 소켓 이벤트
    func onSocketEvent(eventName: String, description: String) {
        print("🌐 이벤트: \(eventName) - \(description)")
    }
}
