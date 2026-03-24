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
                    TextField("이메일", text: $userId)
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
                        
                        Text("이메일 / 비밀번호 찾기")
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
    // ────────────────────────────────────────
    // 서버에 로그인 요청
    // ────────────────────────────────────────
    func loginAction() {
        if userId.isEmpty || password.isEmpty {
            alertMessage = "이메일과 비밀번호를 모두 입력해주세요."
            showAlert = true
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/auth/login") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 💡 수정 포인트 1: 서버 DTO에 맞춰 "userId" 키를 "email"로 변경!
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": userId,
            "password": password
        ])
        
        // loginAction 함수 내의 URLSession 부분 수정
        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                guard let data = data else { return }
                let httpResponse = response as? HTTPURLResponse
                
                if httpResponse?.statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let responseData = json["data"] as? [String: Any] {
                        
                        // 1. 토큰 저장
                        if let token = responseData["token"] as? String {
                            UserDefaults.standard.set(token, forKey: "jwtToken")
                        }
                        
                        // 2. 내 유저 ID 저장 🚀
                        if let id = responseData["userId"] as? Int {
                            UserDefaults.standard.set(id, forKey: "myUserId")
                        }
                    }
                    isLoginSuccess = true
                }
            }
        }.resume()    }
}

#Preview {
    LoginView()
}
