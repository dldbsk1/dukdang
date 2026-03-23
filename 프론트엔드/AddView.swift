import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var originalPrice: String = ""
    @State private var locationTag: String = ""
    
    // 알림창 상태 관리
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 카메라 버튼
                    Button(action: { }) {
                        VStack(spacing: 5) {
                            Image(systemName: "camera.fill").font(.system(size: 24))
                            Text("0/10").font(.system(size: 12))
                        }
                        .foregroundColor(.gray)
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    Divider()
                    
                    // 제목
                    VStack(alignment: .leading, spacing: 10) {
                        Text("제목")
                            .font(.system(size: 16, weight: .bold))
                        TextField("글 제목을 입력해주세요", text: $title)
                            .font(.system(size: 16))
                    }
                    
                    Divider()
                    
                    // 자세한 설명 섹션
                    VStack(alignment: .leading, spacing: 10) {
                        Text("자세한 설명")
                            .font(.system(size: 16, weight: .bold))
                        
                        ZStack(alignment: .topLeading) {
                            // 힌트 글자
                            if description.isEmpty {
                                Text("게시글 내용을 작성해주세요.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                            }
                            
                            // 입력창
                            TextEditor(text: $description)
                                .font(.system(size: 15))
                                .frame(minHeight: 150)
                                .padding(8)
                                .scrollContentBackground(.hidden)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Divider()
                    
                    // 원가 (판매 가격)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("가격")
                            .font(.system(size: 16, weight: .bold))
                        HStack {
                            Text("₩").foregroundColor(.black)
                            TextField("가격을 입력해주세요", text: $originalPrice)
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    Divider()
                    
                    // 위치
                    VStack(alignment: .leading, spacing: 10) {
                        Text("위치")
                            .font(.system(size: 16, weight: .bold))
                        HStack(spacing: 5) {
                            Text("#")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.orange)
                            TextField("위치를 입력해주세요", text: $locationTag)
                        }
                    }
                }
                .padding(20)
            }
            
            // 작성 완료 버튼
            VStack {
                Divider()
                Button(action: {
                    uploadPostAction()
                }) {
                    Text("작성 완료")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.orange)
                        .cornerRadius(12)
                        .padding()
                }
            }
            .background(Color.white)
        }
        .navigationTitle("내 물건 팔기")
        .navigationBarTitleDisplayMode(.inline)
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) {
                if isSuccess {
                    dismiss() // 성공 시에만 화면 닫기
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // ────────────────────────────────────────
    // 서버에 게시글 작성 요청
    // POST /trade-posts
    // ────────────────────────────────────────
    func uploadPostAction() {
        // 1. 입력값 검증
        if title.isEmpty || description.isEmpty || originalPrice.isEmpty {
            alertMessage = "제목, 설명, 가격을 모두 입력해주세요."
            showAlert = true
            return
        }
        
        let priceInt = Int(originalPrice) ?? 0
        
        // 위치 태그가 있으면 설명 맨 밑에 붙여주기
        let finalDescription = locationTag.isEmpty ? description : "\(description)\n\n#\(locationTag)"
        
        // 2. URL 및 Request 설정
        guard let url = URL(string: "http://localhost:8080/trade-posts") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 💡 로그인 시 저장해둔 JWT 토큰 꺼내서 헤더에 넣기
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            alertMessage = "로그인이 필요합니다."
            showAlert = true
            return
        }
        
        // 3. Body 데이터 생성
        // 주의: Category는 백엔드 Enum(Category.java)에 있는 문자열과 정확히 일치해야 합니다.
        // 현재 화면에 카테고리 선택이 없어서 임시로 "ETC"(기타)로 보냅니다.
        let bodyData: [String: Any] = [
                    "title": title,
                    "description": finalDescription,
                    "price": priceInt,
                    // 💡 "ETC"를 지우고 백엔드 Enum에 있는 "ELECTRONICS", "BOOK", "CLOTHES" 중 하나로 변경!
                    "category": "ELECTRONICS",
                    "imageUrl": ""
                ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        
        // 4. 통신 시작
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    alertMessage = "네트워크 에러: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                let httpResponse = response as? HTTPURLResponse
                
                // 백엔드 생성 성공(201) 또는 성공(200)
                if let statusCode = httpResponse?.statusCode, (200...299).contains(statusCode) {
                    alertMessage = "게시글이 등록되었습니다."
                    isSuccess = true
                    showAlert = true
                } else {
                    // 실패 시 에러 메시지
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMsg = json["message"] as? String {
                        alertMessage = "등록 실패: \(errorMsg)"
                    } else {
                        alertMessage = "게시글 등록에 실패했습니다. (코드: \(httpResponse?.statusCode ?? 0))"
                    }
                    showAlert = true
                }
            }
        }.resume()
    }
}

#Preview {
    NavigationStack {
        AddView()
    }
}
