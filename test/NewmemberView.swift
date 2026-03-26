import SwiftUI
 
struct NewmemberView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var nickname: String = ""
    @State private var userId: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var nicknameChecked = false
    @State private var nicknameAvailable: Bool? = nil
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image("logo")
                .resizable()
                .frame(width: 100, height: 100)
            
            VStack(spacing: 10) {
                TextField("닉네임", text: $nickname)
                    .padding(12)
                    .frame(width: 280, height: 50)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .autocapitalization(.none)
                    .onChange(of: nickname) { _ in
                        // 닉네임 바뀌면 중복확인 초기화
                        nicknameChecked = false
                        nicknameAvailable = nil
                    }
                
                HStack {
                    Button("중복확인") { checkNickname() }
                        .font(.system(size: 12))
                    Spacer()
                    if let available = nicknameAvailable {
                        Text(available ? "닉네임 사용 가능!" : "닉네임 사용 불가!")
                            .font(.system(size: 12))
                            .foregroundColor(available ? .blue : .red)
                    }
                }
                .frame(width: 280)
                
                TextField("아이디", text: $userId)
                    .padding(12)
                    .frame(width: 280, height: 50)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1))
                    .autocapitalization(.none)
                
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
    // 서버에 닉네임 중복확인 요청
    // GET /check-nickname?nickname=홍길동
    // ────────────────────────────────────────
    func checkNickname() {
        if nickname.isEmpty {
            alertMessage = "닉네임을 입력해주세요."
            showAlert = true
            return
        }
        
        // 닉네임을 URL에 넣을 수 있게 인코딩 (한글 처리)
        guard let encodedNickname = nickname.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://localhost:8080/check-nickname?nickname=\(encodedNickname)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, _ in
            DispatchQueue.main.async {
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    alertMessage = "서버 연결에 실패했습니다."
                    showAlert = true
                    return
                }
                
                let available = json["available"] as? Bool ?? false
                nicknameChecked = true
                nicknameAvailable = available
            }
        }.resume()
    }
    
    // ────────────────────────────────────────
    // 서버에 회원가입 요청
    // POST /signup
    // ────────────────────────────────────────
    func signUpAction() {
        // 입력값 검증 (서버 요청 전에 앱에서 먼저 체크)
        if nickname.isEmpty || userId.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "모든 항목을 입력해주세요."
            showAlert = true
            return
        }
        if !nicknameChecked {
            alertMessage = "닉네임 중복 확인을 해주세요."
            showAlert = true
            return
        }
        if nicknameAvailable == false {
            alertMessage = "닉네임을 변경해주세요."
            showAlert = true
            return
        }
        if password != confirmPassword {
            alertMessage = "비밀번호가 일치하지 않습니다."
            showAlert = true
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/signup") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "userId": userId,
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
                
                if httpResponse?.statusCode == 200 {
                    // 회원가입 성공 → 로그인 화면으로 돌아가기
                    alertMessage = "회원가입 완료!"
                    showAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        dismiss()
                    }
                } else {
                    // 실패 (아이디/닉네임 중복 등)
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMsg = json["error"] as? String {
                        alertMessage = errorMsg
                    } else {
                        alertMessage = "회원가입에 실패했습니다."
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
 
