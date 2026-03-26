import SwiftUI
import PhotosUI

// 💡 AI 응답을 받을 구조체
struct AICategoryResponse: Codable {
    let category: String
    let reason: String
    let confidence: Double
}

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var originalPrice: String = ""
    
    // 카테고리 관련 변수들
    @State private var selectedCategory: String = "ETC"
    @State private var isAiLoading: Bool = false
    @State private var aiReason: String = ""
    
    // 백엔드 Enum과 똑같이 맞춘 카테고리 목록
    let categories = [
        ("FASHION", "의류/잡화"), ("BOOK", "서적"), ("ELECTRONICS", "전자기기"),
        ("LIVING", "생활용품"), ("FURNITURE", "자취/가구"), ("FOOD", "식품/간식"),
        ("TICKET", "티켓/양도"), ("ASSIGNMENT", "과제/자료"), ("ETC", "기타")
    ]
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var selectedImagesBase64: [String] = []
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isUploading = false
    
    let customBlue = Color(red: 0.18, green: 0.28, blue: 0.5)
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 사진 미리보기 영역
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images, photoLibrary: .shared()) {
                                VStack(spacing: 5) {
                                    Image(systemName: "camera.fill").font(.system(size: 24))
                                    Text("\(selectedImages.count)/10").font(.system(size: 12))
                                }
                                .foregroundColor(.gray)
                                .frame(width: 80, height: 80)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            ForEach(0..<selectedImages.count, id: \.self) { index in
                                Image(uiImage: selectedImages[index])
                                    .resizable().scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10).clipped()
                            }
                        }
                    }
                    .padding(.top, 10)
                    Divider()
                    
                    // 제목 입력
                    VStack(alignment: .leading, spacing: 10) {
                        Text("제목").font(.system(size: 16, weight: .bold))
                        TextField("글 제목을 입력해주세요", text: $title).font(.system(size: 16))
                    }
                    Divider()
                    
                    // 설명 입력
                    VStack(alignment: .leading, spacing: 10) {
                        Text("자세한 설명").font(.system(size: 16, weight: .bold))
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("게시글 내용을 작성해주세요.").font(.system(size: 15)).foregroundColor(.gray).padding(12)
                            }
                            TextEditor(text: $description).font(.system(size: 15)).frame(minHeight: 100).padding(8).scrollContentBackground(.hidden)
                        }.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    
                    // 💡 [수정] 하늘색 테마 + 이모지 제거!
                    Button(action: { recommendCategoryByAI() }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text(isAiLoading ? "AI가 생각하는 중..." : "AI 카테고리 자동 추천받기") // 👈 ✨ 제거!
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isAiLoading ? Color.gray : (title.isEmpty ? Color.gray.opacity(0.5) : customBlue)) // 👈 남색 적용
                        .cornerRadius(8)                    }
                    .disabled(isAiLoading || title.isEmpty)
                    
                    if !aiReason.isEmpty {
                        Text("💡 AI 추천 이유: \(aiReason)")
                            .font(.caption)
                            .foregroundColor(customBlue) //👈 색상 통일
                    }
                    
                    Divider()
                    
                    // 카테고리 선택 피커
                    VStack(alignment: .leading, spacing: 10) {
                        Text("카테고리").font(.system(size: 16, weight: .bold))
                        Picker("카테고리 선택", selection: $selectedCategory) {
                            ForEach(categories, id: \.0) { cat in
                                Text(cat.1).tag(cat.0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(8)
                    }
                    Divider()
                    
                    // 가격 입력
                    VStack(alignment: .leading, spacing: 10) {
                        Text("가격").font(.system(size: 16, weight: .bold))
                        HStack {
                            Text("₩").foregroundColor(.black)
                            TextField("가격을 입력해주세요", text: $originalPrice).keyboardType(.numberPad)
                        }
                    }
                }
                .padding(20)
            }
            
            VStack {
                Divider()
                Button(action: { uploadPostAction() }) {
                    Text(isUploading ? "등록 중..." : "작성 완료").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 55)
                        .background(isUploading ? Color.gray : Color.cyan).cornerRadius(12).padding()
                }.disabled(isUploading)
            }.background(Color.white)
        }
        .navigationTitle("내 물건 팔기").navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItems) { newItems in
            selectedImages.removeAll(); selectedImagesBase64.removeAll()
            for item in newItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.selectedImages.append(image)
                            if let compressedData = image.jpegData(compressionQuality: 0.8) {
                                self.selectedImagesBase64.append("data:image/jpeg;base64," + compressedData.base64EncodedString())
                            }
                        }
                    }
                }
            }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) { if isSuccess { dismiss() } }
        } message: { Text(alertMessage) }
    }
    
    // 💡 AI 서비스 호출 로직 (사진 포함 버전!)
    func recommendCategoryByAI() {
        isAiLoading = true
        guard let url = URL(string: "http://localhost:8080/ai/category") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
            
        // 💡 [핵심 추가] 사용자가 선택한 사진이 있다면, 그중 첫 번째 사진을 뽑아서 AI에게 같이 보냅니다!
        var body: [String: String] = ["title": title, "description": description]
        if let firstImage = selectedImagesBase64.first {
            body["imageBase64"] = firstImage // 사진 추가!
        }
            
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
            
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isAiLoading = false
                guard let data = data, error == nil else { print("AI 네트워크 에러"); return }
                do {
                    let decoded = try JSONDecoder().decode(SimpleAPIResponse<AICategoryResponse>.self, from: data)
                    if let aiData = decoded.data {
                        self.selectedCategory = aiData.category
                        self.aiReason = aiData.reason
                    }
                } catch { print("❌ AI 파싱 에러: \\(error)") }
            }
        }.resume()
    }
    func uploadPostAction() {
        if title.isEmpty || description.isEmpty || originalPrice.isEmpty {
            alertMessage = "제목, 설명, 가격을 모두 입력해주세요."; showAlert = true; return
        }
        
        let priceInt = Int(originalPrice) ?? 0
        
        guard let url = URL(string: "http://localhost:8080/trade-posts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let bodyData: [String: Any] = [
            "title": title, "description": description, "price": priceInt,
            "category": selectedCategory, // AI가 맞춰준 카테고리 전송!
            "imageUrls": selectedImagesBase64
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        isUploading = true
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUploading = false
                if let error = error { alertMessage = "네트워크 에러: \(error.localizedDescription)"; showAlert = true; return }
                let httpResponse = response as? HTTPURLResponse
                if let statusCode = httpResponse?.statusCode, (200...299).contains(statusCode) {
                    alertMessage = "게시글이 등록되었습니다."; isSuccess = true; showAlert = true
                } else {
                    alertMessage = "게시글 등록에 실패했습니다."
                    showAlert = true
                }
            }
        }.resume()
    }
}
