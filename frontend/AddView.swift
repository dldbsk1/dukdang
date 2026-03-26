import SwiftUI
import PhotosUI

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var originalPrice: String = ""
    @State private var locationTag: String = ""
    
    // 💡 [수정] 여러 장을 담기 위해 모두 배열([])로 변경!
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []
    @State private var selectedImagesBase64: [String] = []
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    @State private var isUploading = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 💡 [수정] 가로 스크롤 미리보기 영역
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // 💡 maxSelectionCount를 10으로 설정해 최대 10장 제한!
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
                            
                            // 선택된 사진들 옆으로 나열하기
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("제목").font(.system(size: 16, weight: .bold))
                        TextField("글 제목을 입력해주세요", text: $title).font(.system(size: 16))
                    }
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("자세한 설명").font(.system(size: 16, weight: .bold))
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("게시글 내용을 작성해주세요.").font(.system(size: 15)).foregroundColor(.gray).padding(12)
                            }
                            TextEditor(text: $description).font(.system(size: 15)).frame(minHeight: 150).padding(8).scrollContentBackground(.hidden)
                        }.overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                    }
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("가격").font(.system(size: 16, weight: .bold))
                        HStack {
                            Text("₩").foregroundColor(.black)
                            TextField("가격을 입력해주세요", text: $originalPrice).keyboardType(.numberPad)
                        }
                    }
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("위치").font(.system(size: 16, weight: .bold))
                        HStack(spacing: 5) {
                            Text("#").font(.system(size: 18, weight: .bold)).foregroundColor(.orange)
                            TextField("위치를 입력해주세요", text: $locationTag)
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
                        .background(isUploading ? Color.gray : Color.orange).cornerRadius(12).padding()
                }.disabled(isUploading)
            }.background(Color.white)
        }
        .navigationTitle("내 물건 팔기").navigationBarTitleDisplayMode(.inline)
        // 💡 [수정] 여러 장의 사진을 비동기로 돌면서 Base64 텍스트로 전부 변환
        .onChange(of: selectedItems) { newItems in
            selectedImages.removeAll()
            selectedImagesBase64.removeAll()
            
            for item in newItems {
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.selectedImages.append(image)
                            if let compressedData = image.jpegData(compressionQuality: 1.0) {
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
    
    func uploadPostAction() {
        if title.isEmpty || description.isEmpty || originalPrice.isEmpty {
            alertMessage = "제목, 설명, 가격을 모두 입력해주세요."; showAlert = true; return
        }
        
        let priceInt = Int(originalPrice) ?? 0
        let finalDescription = locationTag.isEmpty ? description : "\(description)\n\n#\(locationTag)"
        
        guard let url = URL(string: "http://localhost:8080/trade-posts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // 💡 [수정] "imageUrl" 대신 배열인 "imageUrls" 로 보냅니다!
        let bodyData: [String: Any] = [
            "title": title, "description": finalDescription, "price": priceInt,
            "category": "ELECTRONICS",
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
