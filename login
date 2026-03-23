import SwiftUI

struct LoginView: View {
    @State private var userId: String = ""
    @State private var password: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var isLoginSuccess = false
    @State private var goToSignUp = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer().frame(height: 170)
                
                Image("logo")
                    .resizable()
                    .frame(width: 100, height: 100)
                
                VStack(spacing: 10) {
                    TextField("아이디", text: $userId)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .frame(width: 280, height: 44)
                        .autocapitalization(.none)
                    
                    SecureField("비밀번호", text: $password)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .frame(width: 280, height: 44)
                }
                
                VStack(spacing: 8) {
                    Button(action: { loginAction() }) {
                        Text("로그인")
                            .foregroundColor(.black)
                            .frame(width: 280, height: 44)
                            .background(Color(red: 0.75, green: 0.9, blue: 1.0))
                            .cornerRadius(25)
                    }
                    
                    HStack {
                        Button(action: { goToSignUp = true }) {
                            Text("회원가입")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Text("아이디 / 비밀번호 찾기")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    .frame(width: 280)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goToSignUp) {
                NewmemberView()
            }
        }
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $isLoginSuccess) {
            MainView()
        }
    }
    
    // ────────────────────────────────────────
    // 서버에 로그인 요청
    // ────────────────────────────────────────
    func loginAction() {
        if userId.isEmpty || password.isEmpty {
            alertMessage = "아이디와 비밀번호를 모두 입력해주세요."
            showAlert = true
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "userId": userId,
            "password": password
        ])
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                guard let data = data else {
                    alertMessage = "서버 연결에 실패했습니다."
                    showAlert = true
                    return
                }
                
                // HTTP 상태코드 확인
                let httpResponse = response as? HTTPURLResponse
                
                if httpResponse?.statusCode == 200 {
                    // 로그인 성공
                    isLoginSuccess = true
                } else {
                    // 로그인 실패 (401)
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMsg = json["error"] as? String {
                        alertMessage = errorMsg
                    } else {
                        alertMessage = "아이디 또는 비밀번호가 틀렸습니다."
                    }
                    showAlert = true
                }
            }
        }.resume()
    }
}

#Preview {
    LoginView()
}
