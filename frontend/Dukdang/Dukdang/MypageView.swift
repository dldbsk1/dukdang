import SwiftUI
import PhotosUI

// MARK: - API 통신용 구조체
struct UserProfileResponse: Codable {
    let name: String
    let profileImageName: String?
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

struct MyAuctionPostResponse: Codable {
    let id: Int
    let title: String
    let minPrice: Int
    let imageUrl: String?
    let status: String
    let postTime: String
}

// MARK: - UI 데이터 모델
struct UserProfile {
    var name: String; var profileImageName: String; var location: String; var temperature: Double; var tradeCount: Int
}

enum TradeType {
    case buy, sell, auction
    var label: String { switch self { case .buy: return "구매"; case .sell: return "판매"; case .auction: return "경매" } }
    var color: Color { switch self { case .buy: return .green; case .sell: return .blue; case .auction: return .orange } }
}

enum TradeStatusUI {
    case completed, inProgress, cancelled, reserved
    var label: String { switch self { case .completed: return "거래완료"; case .inProgress: return "판매중/진행중"; case .cancelled: return "취소/유찰"; case .reserved: return "예약중" } }
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
    let rawDate: Date
}

struct SettingItem: Identifiable { let id = UUID(); let icon: String; let title: String }
let settingItems: [SettingItem] = [
    SettingItem(icon: "bell", title: "알림 설정"), SettingItem(icon: "lock", title: "개인정보 보호"),
    SettingItem(icon: "questionmark.circle", title: "고객센터"), SettingItem(icon: "arrow.right.square", title: "로그아웃")
]

struct EditPostWrapper: Identifiable {
    let id: Int
}

// MARK: - 마이페이지 메인 뷰
struct MypageView: View {
    @State private var user = UserProfile(name: "불러오는 중...", profileImageName: "profile", location: "", temperature: 36.5, tradeCount: 0)
    @State private var tradeHistory: [TradeHistory] = []
    
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    
    @State private var editPostWrapper: EditPostWrapper? = nil
    
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
                fetchMyProfile()
                loadAllHistory()
            }
        }
        .sheet(isPresented: $showEditProfile) { EditProfileView(user: $user) }
        .sheet(item: $editPostWrapper) { wrapper in
            EditTradePostView(postId: wrapper.id) { loadAllHistory() }
        }
        .alert("로그아웃", isPresented: $showLogoutAlert) {
            Button("확인", role: .destructive) { UserDefaults.standard.removeObject(forKey: "jwtToken"); dismiss() }
            Button("닫기", role: .cancel) {}
        } message: { Text("로그아웃 하시겠어요?") }
    }
    
    func loadAllHistory() {
        self.tradeHistory.removeAll()
        fetchMyTradeHistory()
        fetchMyAuctions()
    }

    func fetchMyProfile() {
        guard let url = URL(string: "http://localhost:8080/api/users/me") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(SimpleAPIResponse<UserProfileResponse>.self, from: data) {
                DispatchQueue.main.async { if let p = decoded.data { self.user = UserProfile(name: p.name, profileImageName: p.profileImageName ?? "profile", location: p.location ?? "", temperature: p.temperature ?? 36.5, tradeCount: p.tradeCount) } }
            }
        }.resume()
    }

    func fetchMyTradeHistory() {
        guard let url = URL(string: "http://localhost:8080/trade-posts/my-posts") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(SimpleAPIResponse<[MyTradePostResponse]>.self, from: data) {
                DispatchQueue.main.async {
                    if let posts = decoded.data {
                        let newItems = posts.map { post in
                            let uiStatus: TradeStatusUI = (post.status == "SALE") ? .inProgress : ((post.status == "SOLD") ? .completed : .reserved)
                            return TradeHistory(postId: post.id, title: post.title, price: post.price, imageName: post.imageUrl?.isEmpty == false ? post.imageUrl! : "logo", type: .sell, status: uiStatus, date: String(post.postTime.prefix(10)), rawDate: parseDate(post.postTime))
                        }
                        self.tradeHistory.append(contentsOf: newItems)
                        self.tradeHistory.sort { $0.rawDate > $1.rawDate }
                    }
                }
            }
        }.resume()
    }
    
    func fetchMyAuctions() {
        guard let url = URL(string: "http://localhost:8080/auctions/my-auctions") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let decoded = try? JSONDecoder().decode(SimpleAPIResponse<[MyAuctionPostResponse]>.self, from: data) {
                DispatchQueue.main.async {
                    if let posts = decoded.data {
                        let newItems = posts.map { post in
                            let uiStatus: TradeStatusUI = (post.status == "ENDED" || post.status == "COMPLETED") ? .completed : ((post.status == "CANCELLED") ? .cancelled : .inProgress)
                            return TradeHistory(postId: post.id, title: post.title, price: post.minPrice, imageName: post.imageUrl?.isEmpty == false ? post.imageUrl! : "logo", type: .auction, status: uiStatus, date: String(post.postTime.prefix(10)), rawDate: parseDate(post.postTime))
                        }
                        self.tradeHistory.append(contentsOf: newItems)
                        self.tradeHistory.sort { $0.rawDate > $1.rawDate }
                    }
                }
            }
        }.resume()
    }

    func changePostStatus(postId: Int, newStatus: String) {
        guard let url = URL(string: "http://localhost:8080/trade-posts/\(postId)/status?status=\(newStatus)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let http = response as? HTTPURLResponse, http.statusCode == 200 { DispatchQueue.main.async { loadAllHistory() } }
        }.resume()
    }
    
    func deletePost(postId: Int) {
        guard let url = URL(string: "http://localhost:8080/trade-posts/\(postId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) { DispatchQueue.main.async { loadAllHistory() } }
        }.resume()
    }
    
    func parseDate(_ str: String) -> Date {
        let formatter = DateFormatter(); formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let d = formatter.date(from: str) { return d }; formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"; return formatter.date(from: str) ?? Date()
    }

    // MARK: - UI 섹션들
    private var profileSection: some View {
        HStack(spacing: 16) {
            if user.profileImageName.hasPrefix("http") {
                AsyncImage(url: URL(string: user.profileImageName)) { img in
                    img.resizable().scaledToFill()
                } placeholder: { Color.gray.opacity(0.2) }
                .frame(width: 64, height: 64).clipShape(Circle())
            } else {
                Image(user.profileImageName).resizable().frame(width: 64, height: 64).clipShape(Circle())
            }
            
            // 💡 [수정] 닉네임 밑에 뜨던 동네 텍스트를 지웠습니다!
            VStack(alignment: .leading, spacing: 4) { Text(user.name).font(.title3).bold(); Text("거래 \(user.tradeCount)회").font(.caption).foregroundColor(.gray) }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Button(action: { showEditProfile = true }) { Text("정보 수정").font(.caption).padding(.horizontal, 10).padding(.vertical, 5).background(Color.gray.opacity(0.15)).cornerRadius(6).foregroundColor(.primary) }
            }
        }.padding()
    }

    private var tradeHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("내 활동 내역").font(.headline).padding(.horizontal)
            if tradeHistory.isEmpty { Text("등록된 내역이 없습니다.").foregroundColor(.gray).padding(.horizontal) } else {
                ForEach(tradeHistory) { trade in
                    HStack(spacing: 12) {
                        if trade.imageName.hasPrefix("http") { AsyncImage(url: URL(string: trade.imageName)) { img in img.resizable().scaledToFill() } placeholder: { Color.gray.opacity(0.2) }.frame(width: 56, height: 56).cornerRadius(8).clipped() }
                        else { Image(trade.imageName).resizable().scaledToFill().frame(width: 56, height: 56).cornerRadius(8).clipped() }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trade.title).font(.subheadline).bold().lineLimit(1)
                            Text(trade.price.wonFormatted).font(.caption).foregroundColor(.gray)
                            Text(trade.date).font(.caption2).foregroundColor(.gray)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(trade.type.label).font(.caption2).padding(.horizontal, 8).padding(.vertical, 3).background(trade.type.color.opacity(0.15)).foregroundColor(trade.type.color).cornerRadius(6)
                            Text(trade.status.label).font(.caption2).foregroundColor(.gray)
                        }
                        
                        if trade.type == .sell {
                            Menu {
                                Menu("상태 변경") {
                                    Button("판매중") { changePostStatus(postId: trade.postId, newStatus: "SALE") }
                                    Button("예약중") { changePostStatus(postId: trade.postId, newStatus: "RESERVED") }
                                    Button("거래완료") { changePostStatus(postId: trade.postId, newStatus: "SOLD") }
                                }
                                Button("게시글 수정") { editPostWrapper = EditPostWrapper(id: trade.postId) }
                                Button("삭제하기", role: .destructive) { deletePost(postId: trade.postId) }
                            } label: {
                                Image(systemName: "ellipsis").padding(.horizontal, 8).foregroundColor(.gray)
                            }
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
                    HStack { Image(systemName: item.icon).frame(width: 24).foregroundColor(.gray); Text(item.title).foregroundColor(.primary); Spacer(); Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption) }.padding()
                }
                Divider().padding(.leading)
            }
        }.padding(.vertical, 8)
    }
}

// MARK: - 회원정보 수정 뷰
struct EditProfileView: View {
    @Binding var user: UserProfile; @Environment(\.dismiss) var dismiss
    @State private var name: String; @State private var isSaving = false
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedImageBase64: String?
    
    init(user: Binding<UserProfile>) {
        self._user = user
        self._name = State(initialValue: user.wrappedValue.name)
    }
    
    var canSave: Bool { return !name.isEmpty && !isSaving }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 8) {
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage).resizable().scaledToFill()
                            }
                            else if user.profileImageName.hasPrefix("http") {
                                AsyncImage(url: URL(string: user.profileImageName)) { img in
                                    img.resizable().scaledToFill()
                                } placeholder: { Color.gray.opacity(0.2) }
                            } else {
                                Image(user.profileImageName).resizable().frame(width: 80, height: 80)
                            }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        
                        Text("사진 변경").font(.caption).foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 24)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.selectedImage = image
                                if let compressed = image.jpegData(compressionQuality: 0.5) {
                                    self.selectedImageBase64 = "data:image/jpeg;base64," + compressed.base64EncodedString()
                                }
                            }
                        }
                    }
                }
                
                Divider()
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) { Text("닉네임").font(.caption).foregroundColor(.gray); TextField("닉네임을 입력하세요", text: $name).padding().background(Color.gray.opacity(0.08)).cornerRadius(8) }.padding()
                    // 💡 [수정] 동네 입력칸 삭제!
                }; Spacer()
                Button(action: { updateProfile() }) { Text(isSaving ? "저장 중..." : "저장하기").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity).padding().background(canSave ? Color.blue : Color.gray).cornerRadius(12) }.disabled(!canSave).padding()
            }
            .navigationTitle("회원정보 수정").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("취소") { dismiss() } } }
        }
    }
    
    func updateProfile() {
        isSaving = true; guard let url = URL(string: "http://localhost:8080/api/users/me") else { return }
        var request = URLRequest(url: url); request.httpMethod = "PUT"; request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        
        let imageToSend = selectedImageBase64 ?? user.profileImageName
        // 💡 [수정] 백엔드 요청에는 빈 값을 넣어주면 에러를 피할 수 있습니다!
        let body: [String: String] = ["name": name, "location": user.location, "profileImageName": imageToSend]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSaving = false
                if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                    user.name = name
                    dismiss()
                } else {
                    print("저장 실패")
                }
            }
        }.resume()
    }
}

// MARK: - 게시글 수정 화면
struct EditTradePostView: View {
    let postId: Int; var onSave: () -> Void; @Environment(\.dismiss) var dismiss
    @State private var title = ""; @State private var description = ""; @State private var price = ""; @State private var category = "기타"; @State private var imageUrls: [String] = []
    @State private var isLoading = true; @State private var isSaving = false
    
    struct FullPostDetail: Codable {
        let title: String?
        let description: String?
        let price: Int?
        let category: String?
        let imageUrls: [String]?
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("정보 불러오는 중...")
                } else {
                    Form {
                        Section(header: Text("상품 정보")) {
                            TextField("제목", text: $title)
                            TextField("가격 (원)", text: $price).keyboardType(.numberPad)
                            Picker("카테고리", selection: $category) {
                                ForEach(["CLOTHES", "BOOK", "ELECTRONICS"], id: \.self) { Text($0).tag($0) }
                            }
                        }
                        Section(header: Text("상세 설명")) {
                            TextEditor(text: $description).frame(height: 150)
                        }
                    }
                }
            }
            .navigationTitle("게시글 수정").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("취소") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("저장") { updatePost() }.disabled(isSaving || title.isEmpty || price.isEmpty) }
            }
            .onAppear { fetchPostDetail() }
        }
    }
    
    func fetchPostDetail() {
        guard let url = URL(string: "http://localhost:8080/trade-posts/\(postId)") else { return }
        var request = URLRequest(url: url)
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data else {
                    self.isLoading = false
                    print("데이터 없음 에러")
                    return
                }
                
                do {
                    let decoded = try JSONDecoder().decode(SimpleAPIResponse<FullPostDetail>.self, from: data)
                    if let d = decoded.data {
                        self.title = d.title ?? ""
                        self.description = d.description ?? ""
                        self.price = "\(d.price ?? 0)"
                        self.category = d.category ?? "기타"
                        self.imageUrls = d.imageUrls ?? []
                    }
                    self.isLoading = false
                } catch {
                    print("❌ 디코딩 에러 발생: \(error)")
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    func updatePost() {
        isSaving = true; guard let url = URL(string: "http://localhost:8080/trade-posts/\(postId)") else { return }
        var request = URLRequest(url: url); request.httpMethod = "PUT"; request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        let body: [String: Any] = ["title": title, "description": description, "price": Int(price) ?? 0, "category": category, "imageUrls": imageUrls]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { _, response, _ in DispatchQueue.main.async { isSaving = false; if let http = response as? HTTPURLResponse, http.statusCode == 200 { onSave(); dismiss() } } }.resume()
    }
}
