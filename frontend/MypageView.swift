import SwiftUI

// MARK: - 1. API 통신용 구조체 (안전장치 포함)

struct UserProfileResponse: Codable {
    let name: String
    let profileImageName: String?
    // 💡 [핵심] 예전 계정들의 null 값을 대비해 옵셔널(?)로 선언합니다.
    let location: String?
    let temperature: Double?
    let tradeCount: Int
}

struct MyTradePostResponse: Codable {
    let id: Int
    let title: String
    let price: Int
    let imageUrl: String?
    let status: String
    let postTime: String
}

// MARK: - 2. UI 데이터 모델 (기존과 동일)

struct UserProfile {
    var name: String
    var profileImageName: String
    var location: String
    var temperature: Double
    var tradeCount: Int
}

enum TradeType {
    case buy, sell, auction
    var label: String {
        switch self { case .buy: return "구매"; case .sell: return "판매"; case .auction: return "경매" }
    }
    var color: Color {
        switch self { case .buy: return .green; case .sell: return .blue; case .auction: return .orange }
    }
}

enum TradeStatusUI {
    case completed, inProgress, cancelled
    var label: String {
        switch self { case .completed: return "거래완료"; case .inProgress: return "판매중"; case .cancelled: return "취소됨" }
    }
}

struct TradeHistory: Identifiable {
    let id = UUID()
    let postId: Int
    let title: String
    let price: Int
    let imageName: String
    let type: TradeType
    let status: TradeStatusUI
    let date: String
}

// MARK: - 설정 항목
struct SettingItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

let settingItems: [SettingItem] = [
    SettingItem(icon: "bell", title: "알림 설정"),
    SettingItem(icon: "lock", title: "개인정보 보호"),
    SettingItem(icon: "questionmark.circle", title: "고객센터"),
    SettingItem(icon: "arrow.right.square", title: "로그아웃"),
]

// MARK: - 3. 회원정보 수정 뷰 (API 연결)
struct EditProfileView: View {
    @Binding var user: UserProfile
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var location: String
    @State private var isSaving = false // 💡 저장 중 로딩 상태

    init(user: Binding<UserProfile>) {
        self._user = user
        self._name = State(initialValue: user.wrappedValue.name)
        self._location = State(initialValue: user.wrappedValue.location)
    }

    var canSave: Bool {
        return !name.isEmpty && !location.isEmpty && !isSaving
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Image(user.profileImageName)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
                .padding(.vertical, 24)

                Divider()

                VStack(spacing: 0) {
                    // 닉네임
                    VStack(alignment: .leading, spacing: 6) {
                        Text("닉네임").font(.caption).foregroundColor(.gray)
                        TextField("닉네임을 입력하세요", text: $name)
                            .padding()
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(8)
                    }.padding()

                    Divider()

                    // 동네 설정
                    VStack(alignment: .leading, spacing: 6) {
                        Text("동네").font(.caption).foregroundColor(.gray)
                        TextField("동네를 입력하세요", text: $location)
                            .padding()
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(8)
                    }.padding()
                }
                Spacer()

                // 🚀 서버에 수정 요청 보내기
                Button(action: { updateProfile() }) {
                    Text(isSaving ? "저장 중..." : "저장하기")
                        .font(.headline).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding()
                        .background(canSave ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSave)
                .padding()
            }
            .navigationTitle("회원정보 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }
    
    // ── 프로필 수정 API 호출 ──
    func updateProfile() {
        isSaving = true
        guard let url = URL(string: "http://localhost:8080/api/users/me") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: String] = ["name": name, "location": location, "profileImageName": user.profileImageName]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                isSaving = false
                // 성공적으로 저장되면 UI 즉시 업데이트 후 창 닫기
                user.name = name
                user.location = location
                dismiss()
            }
        }.resume()
    }
}

// MARK: - 4. 마이페이지 메인 뷰
struct MypageView: View {
    // 💡 초기값은 비워두고 화면이 켜질 때 서버에서 채웁니다.
    @State private var user: UserProfile = UserProfile(name: "불러오는 중...", profileImageName: "profile", location: "-", temperature: 36.5, tradeCount: 0)
    @State private var tradeHistory: [TradeHistory] = []
    
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    profileSection
                    Divider().padding(.vertical, 8)
                    tradeHistorySection
                    Divider().padding(.vertical, 8)
                    settingsSection
                }
            }
            .navigationTitle("마이페이지")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // 🚀 화면 켜질 때 내 정보와 거래 내역 불러오기
                fetchMyProfile()
                fetchMyTradeHistory()
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(user: $user)
        }
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("확인", role: .destructive) {
                UserDefaults.standard.removeObject(forKey: "jwtToken") // 토큰 삭제
                dismiss()
            }
            Button("닫기", role: .cancel) {}
        } message: { Text("로그아웃 하시겠어요?") }
    }

    // ── 내 프로필 조회 API ──
    func fetchMyProfile() {
        guard let url = URL(string: "http://localhost:8080/api/users/me") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(SimpleAPIResponse<UserProfileResponse>.self, from: data) {
                DispatchQueue.main.async {
                    if let profileData = decoded.data {
                        // 💡 [안전장치] 예전 계정이라서 값이 null(nil)이면 ?? 뒤의 기본값으로 대체합니다.
                        self.user = UserProfile(
                            name: profileData.name,
                            profileImageName: profileData.profileImageName ?? "profile",
                            location: profileData.location ?? "동네 미설정",
                            temperature: profileData.temperature ?? 36.5,
                            tradeCount: profileData.tradeCount
                        )
                    }
                }
            }
        }.resume()
    }

    // ── 내 거래(판매) 내역 API ──
    func fetchMyTradeHistory() {
        guard let url = URL(string: "http://localhost:8080/trade-posts/my-posts") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(SimpleAPIResponse<[MyTradePostResponse]>.self, from: data) {
                DispatchQueue.main.async {
                    if let posts = decoded.data {
                        // 백엔드 데이터를 iOS UI용 TradeHistory로 변환
                        self.tradeHistory = posts.map { post in
                            let uiStatus: TradeStatusUI = (post.status == "SALE") ? .inProgress : ((post.status == "SOLD") ? .completed : .cancelled)
                            // 날짜 문자열(2026-03-24T12:00:00) 자르기
                            let dateStr = String(post.postTime.prefix(10))
                            
                            return TradeHistory(
                                postId: post.id,
                                title: post.title,
                                price: post.price,
                                imageName: post.imageUrl?.isEmpty == false ? post.imageUrl! : "logo",
                                type: .sell, // 내가 쓴 글이므로 '판매' 고정
                                status: uiStatus,
                                date: dateStr
                            )
                        }
                    }
                }
            }
        }.resume()
    }

    // MARK: - 프로필 섹션 (이하 기존 디자인 코드)
    private var profileSection: some View {
        HStack(spacing: 16) {
            Image(user.profileImageName).resizable().frame(width: 64, height: 64).clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name).font(.title3).bold()
                Text(user.location).font(.caption).foregroundColor(.gray)
                Text("거래 \(user.tradeCount)회").font(.caption).foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(user.temperature, specifier: "%.1f")°C").foregroundColor(.blue).bold()
                    Text("매너온도").font(.caption).foregroundColor(.gray)
                }
                Button(action: { showEditProfile = true }) {
                    Text("정보 수정").font(.caption).padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.gray.opacity(0.15)).cornerRadius(6).foregroundColor(.primary)
                }
            }
        }.padding()
    }

    private var tradeHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("내 거래 내역").font(.headline).padding(.horizontal)
            if tradeHistory.isEmpty {
                Text("등록된 판매 내역이 없습니다.").foregroundColor(.gray).padding(.horizontal)
            } else {
                ForEach(tradeHistory) { trade in
                    HStack(spacing: 12) {
                        if trade.imageName.hasPrefix("http") {
                            AsyncImage(url: URL(string: trade.imageName)) { img in img.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.2) }
                                .frame(width: 56, height: 56).cornerRadius(8).clipped()
                        } else {
                            Image(trade.imageName).resizable().scaledToFill().frame(width: 56, height: 56).cornerRadius(8).clipped()
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trade.title).font(.subheadline).bold()
                            Text(trade.price.wonFormatted).font(.caption).foregroundColor(.gray)
                            Text(trade.date).font(.caption2).foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(trade.type.label).font(.caption2).padding(.horizontal, 8).padding(.vertical, 3)
                                .background(trade.type.color.opacity(0.15)).foregroundColor(trade.type.color).cornerRadius(6)
                            Text(trade.status.label).font(.caption2).foregroundColor(.gray)
                        }
                    }.padding(.horizontal)
                    Divider().padding(.leading, 80)
                }
            }
        }.padding(.vertical, 8)
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("설정").font(.headline).padding(.horizontal).padding(.bottom, 8)
            ForEach(settingItems) { item in
                Button(action: { if item.title == "로그아웃" { showLogoutAlert = true } }) {
                    HStack {
                        Image(systemName: item.icon).frame(width: 24).foregroundColor(.gray)
                        Text(item.title).foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
                    }.padding()
                }
                Divider().padding(.leading)
            }
        }.padding(.vertical, 8)
    }
}
