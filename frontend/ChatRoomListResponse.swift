import Foundation

// 💡 이름을 구분하고 Long -> Int로 수정했습니다.
struct ChatRoomListResponse: Codable, Identifiable {
    var id: Int { roomId }
    let roomId: Int
    let tradePostId: Int
    let tradePostTitle: String
    let tradePostImageUrl: String? // null일 수 있으므로 옵셔널 처리
    let otherUserId: Int
    let otherUserNickname: String
    let lastMessage: String
    let lastMessageAt: String
    let unreadCount: Int
}
