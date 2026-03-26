import SwiftUI
import PhotosUI

struct AuctionAddView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startingPrice: String = ""
    @State private var auctionEndTime: Date = Date().addingTimeInterval(3600 * 24)
    
    // 💡 다중 이미지
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var selectedImagesBase64: [String] = []
    
    // 💡 [추가] 카테고리 & AI 관련 변수들
    @State private var selectedCategory: String = "ETC"
    @State private var isAiLoading: Bool = false
    @State private var aiReason: String = ""
    
    let categories = [
        ("FASHION", "의류/잡화"), ("BOOK", "서적"), ("ELECTRONICS", "전자기기"),
        ("LIVING", "생활용품"), ("FURNITURE", "자취/가구"), ("FOOD", "식품/간식"),
        ("TICKET", "티켓/양도"), ("ASSIGNMENT", "과제/자료"), ("ETC", "기타")
    ]
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isUploading = false
    @State private var isSuccess = false
    
    private var isFormValid: Bool { !title.isEmpty && !description.isEmpty && !startingPrice.isEmpty && !isUploading }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedItems, maxSelectionCount: 10, matching: .images, photoLibrary: .shared()) {
                                VStack(spacing: 5) { Image(systemName: "camera.fill").font(.system(size: 24)); Text("\(selectedImages.count)/10").font(.system(size: 12)) }
                                    .foregroundColor(.gray).frame(width: 80, height: 80).background(Color.gray.opacity(0.1)).cornerRadius(10)
                            }
                            ForEach(0..<selectedImages.count, id: \.self) { index in
                                Image(uiImage: selectedImages[index]).resizable().scaledToFill().frame(width: 80, height: 80).cornerRadius(10).clipped()
                            }
                        }
                    }.padding(.top, 10)
                    
                    Divider()
                    VStack(alignment: .leading, spacing: 10) { Text("제목").font(.system(size: 16, weight: .bold)); TextField("경매 물품 제목을 입력해주세요", text: $title).font(.system(size: 16)) }
                    Divider()
                    VStack(alignment: .leading, spacing: 10) { Text("경매 시작가").font(.system(size: 16, weight: .bold)); HStack { Text("₩").bold(); TextField("가격을 입력해주세요", text: $startingPrice).keyboardType(.numberPad) } }
                    Divider()
                    VStack(alignment: .leading, spacing: 10) { Text("경매 마감 시간").font(.system(size: 16, weight: .bold)); DatePicker("마감 날짜 및 시간", selection: $auctionEndTime, in: Date()..., displayedComponents: [.date, .hourAndMinute]).datePickerStyle(.compact).labelsHidden() }
                    Divider()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("자세한 설명").font(.system(size: 16, weight: .bold))
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty { Text("설명을 적어주세요.").font(.system(size: 15)).foregroundColor(.gray).padding(8) }
                            TextEditor(text: $description).font(.system(size: 15)).frame(minHeight: 150).scrollContentBackground(.hidden)
                        }
                    }
                    
                    // 💡 [핵심 적용] AI 추천 기능 (주황색 테마 + 이모지 제거)
                    Button(action: recommendCategoryByAI) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text(isAiLoading ? "AI가 생각하는 중..." : "AI 카테고리 자동 추천받기")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isAiLoading ? Color.gray : (title.isEmpty ? Color.gray.opacity(0.5) : Color.orange))
                        .cornerRadius(8)
                    }
                    .disabled(isAiLoading || title.isEmpty)
                    
                    if !aiReason.isEmpty {
                        Text("💡 AI 추천 이유: \(aiReason)")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.top, 2)
                    }
                    
                    Divider()
                    
                    // 💡 [핵심 적용] 카테고리 선택 피커 추가
                    VStack(alignment: .leading, spacing: 10) {
                        Text("카테고리").font(.system(size: 16, weight: .bold))
                        Picker("카테고리 선택", selection: $selectedCategory) {
                            ForEach(categories, id: \.0) { cat in
                                Text(cat.1).tag(cat.0)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(8)
                    }
                    
                }.padding(20)
            }
            
            VStack {
                Divider()
                Button(action: uploadAuctionAction) {
                    Text(isUploading ? "등록 중..." : "경매 등록하기").font(.system(size: 18, weight: .bold)).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 55)
                        // 💡 [기존 색상 유지] 메인 버튼은 원래대로 Color.red 유지!
                        .background(isFormValid ? Color.red : Color.gray).cornerRadius(12).padding()
                }.disabled(!isFormValid)
            }.background(Color.white)
        }
        .navigationTitle("경매 물건 올리기").navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItems) { newItems in
            selectedImages.removeAll(); selectedImagesBase64.removeAll()
            for item in newItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.selectedImages.append(image)
                            // 화질 0.1(압축)로 줄여서 서버 에러 방지
                            if let compressed = image.jpegData(compressionQuality: 0.1) {
                                self.selectedImagesBase64.append("data:image/jpeg;base64," + compressed.base64EncodedString())
                            }
                        }
                    }
                }
            }
        }
        .alert("알림", isPresented: $showAlert) { Button("확인", role: .cancel) { if isSuccess { dismiss() } } } message: { Text(alertMessage) }
    }
    
    // 💡 AI 서비스 호출 로직
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
                    let decoded = try JSONDecoder().decode(SimpleAPIResponse<AICategoryResponse>.self,from: data)
                    if let aiData = decoded.data {
                        self.selectedCategory = aiData.category
                        self.aiReason = aiData.reason
                    }
                } catch { print("❌ AI 파싱 에러: \\(error)") }
            }
        }.resume()
    }
    // 💡 API 통신 로직
    func uploadAuctionAction() {
        guard let url = URL(string: "http://localhost:8080/auctions") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"; request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = UserDefaults.standard.string(forKey: "jwtToken") { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let startTimeString = formatter.string(from: Date())
        let endTimeString = formatter.string(from: auctionEndTime)
        
        let bodyData: [String: Any] = [
            "title": title,
            "description": description,
            "minPrice": Int(startingPrice) ?? 0,
            "category": selectedCategory, // 💡 AI가 맞춰준 (혹은 유저가 고른) 카테고리 전송!
            "imageUrls": selectedImagesBase64,
            "startTime": startTimeString,
            "endTime": endTimeString
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData); isUploading = true
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUploading = false
                let httpResponse = response as? HTTPURLResponse
                if let code = httpResponse?.statusCode, (200...299).contains(code) {
                    alertMessage = "경매가 등록되었습니다!"; isSuccess = true; showAlert = true
                } else {
                    let errorCode = httpResponse?.statusCode ?? 0
                    alertMessage = "등록 실패 (에러 코드: \(errorCode))"; showAlert = true
                }
            }
        }.resume()
    }
}
