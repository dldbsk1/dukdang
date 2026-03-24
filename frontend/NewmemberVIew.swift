import SwiftUI
 
struct NewmemberView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var nickname: String = ""
    @State private var userId: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 이메일(아이디) 중복 확인용 상태 변수
    @State private var emailChecked = false
    @State private var emailAvailable: Bool? = nil
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("logo")
                .resizable()
                .frame(width: 100, height: 100)
            
            VStack(spacing: 10) {
                // 1. 닉네임 (중복확인 제거)
                TextField("닉네임", text: $nickname)
                    .padding(12)
                    .frame(width: 280, height: 50)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .autocapitalization(.none)
                
                // 2. 이메일(아이디) 입력
                TextField("이메일을 입력해주세요", text: $userId) // 💡 화면엔 이메일, 속으론 userId
                    .padding(12)
                    .frame(width: 280, height: 50)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .onChange(of: userId) { _ in
                        emailChecked = false
                        emailAvailable = nil
                    }
                
                HStack {
                    Button("중복확인") { checkEmail() }
                        .font(.system(size: 12))
                    Spacer()
                    if let available = emailAvailable {
                        Text(available ? "사용 가능한 이메일입니다!" : "이미 가입된 이메일입니다!")
                            .font(.system(size: 12))
                            .foregroundColor(available ? .blue : .red)
                    }
                }
                .frame(width: 280)
                
                // 3. 비밀번호
                HStack {
                    if showPassword { TextField("비밀번호", text: $password) }
                    else { SecureField("비밀번호", text: $password) }
                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
                .frame(width: 280, height: 50)
                .background(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                
                // 4. 비밀번호 확인
                HStack {
                    if showConfirmPassword { TextField("비밀번호 확인", text: $confirmPassword) }
                    else { SecureField("비밀번호 확인", text: $confirmPassword) }
                    Button { showConfirmPassword.toggle() } label: {
                        Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding(12)
                .frame(width: 280, height: 50)
                .background(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1))
            }
            
            Spacer()
            
            Button(action: { signUpAction() }) {
                Text("회원가입 완료")
                    .foregroundColor(.black)
                    .frame(width: 370, height: 70)
                    .background(Color(red: 0.75, green: 0.9, blue: 1.0))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea()
        .alert("알림", isPresented: $showAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // ────────────────────────────────────────
    // 서버에 이메일 중복확인 요청
    // ────────────────────────────────────────
    func checkEmail() {
        if userId.isEmpty {
            alertMessage = "이메일을 입력해주세요."
            showAlert = true
            return
        }
        
        guard let encodedEmail = userId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:8080/auth/check-email?email=\(encodedEmail)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, _ in
            DispatchQueue.main.async {
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    alertMessage = "서버 연결에 실패했습니다."
                    showAlert = true
                    return
                }
                
                let available = json["available"] as? Bool ?? false
                emailChecked = true
                emailAvailable = available
            }
        }.resume()
    }
    
    // ────────────────────────────────────────
    // 서버에 회원가입 요청
    // ────────────────────────────────────────
    func signUpAction() {
        if nickname.isEmpty || userId.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "모든 항목을 입력해주세요."
            showAlert = true
            return
        }
        if !emailChecked {
            alertMessage = "이메일 중복 확인을 해주세요."
            showAlert = true
            return
        }
        if emailAvailable == false {
            alertMessage = "다른 이메일을 사용해주세요."
            showAlert = true
            return
        }
        if password != confirmPassword {
            alertMessage = "비밀번호가 일치하지 않습니다."
            showAlert = true
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/auth/signup") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 💡 백엔드로 보낼 때만 "email"이라는 이름표를 붙여서 보냅니다!
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "email": userId,
            "password": password,
            "nickname": nickname
        ])
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                guard let data = data else {
                    alertMessage = "서버 연결에 실패했습니다."
                    showAlert = true
                    return
                }
                
                let httpResponse = response as? HTTPURLResponse
                
                if let statusCode = httpResponse?.statusCode, (200...299).contains(statusCode) {
                    alertMessage = "회원가입 완료!"
                    showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                } else {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMsg = json["message"] as? String {
                        alertMessage = errorMsg
                    } else {
                        alertMessage = "회원가입에 실패했습니다. (상태 코드: \(httpResponse?.statusCode ?? 0))"
                    }
                    showAlert = true
                }
            }
        }.resume()
    }
}
#Preview {
    NewmemberView()
}
