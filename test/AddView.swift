import SwiftUI

struct AddView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    // 입력 상태 변수
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    
    // 모든 필드가 채워졌는지 확인하는 계산 속성
    private var isFormValid: Bool {
        !title.isEmpty && !price.isEmpty && !description.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 1. 카메라 버튼
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
                    
                    // 2. 제목 입력
                    VStack(alignment: .leading, spacing: 10) {
                        Text("제목")
                            .font(.system(size: 16, weight: .bold))
                        TextField("글 제목을 입력해주세요", text: $title)
                            .font(.system(size: 16))
                    }
                    
                    Divider()
                    
                    // 3. 가격 입력
                    VStack(alignment: .leading, spacing: 10) {
                        Text("판매 가격")
                            .font(.system(size: 16, weight: .bold))
                        HStack {
                            Text("₩").foregroundColor(.black)
                            TextField("가격을 입력해주세요", text: $price)
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    Divider()
                    
                    // 4. 자세한 설명
                    VStack(alignment: .leading, spacing: 10) {
                        Text("자세한 설명")
                            .font(.system(size: 16, weight: .bold))
                        
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("게시글 내용을 작성해주세요.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                            }
                            
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
                }
                .padding(20)
            }
            
            // 작성 완료 버튼
            VStack {
                Divider()
                Button(action: {
                    if isFormValid {
                        dismiss()
                    }
                }) {
                    Text("작성 완료")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        //조건에 따라 버튼색 변경
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(12)
                        .padding()
                }
                // 조건에 따라 버튼 비활성화
                .disabled(!isFormValid)
            }
            .background(Color.white)
        }
        .navigationTitle("내 물건 팔기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AddView()
    }
}
