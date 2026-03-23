

import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var originalPrice: String = ""
    @State private var locationTag: String = ""
    
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
                            // 힌트 글자 (내용이 비어있을 때만 표시)
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
                            // !!핵심: 배경을 숨겨야 밑에 있는 힌트 글자가 보임
                                .scrollContentBackground(.hidden)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Divider()
                    
                    // 원가
                    VStack(alignment: .leading, spacing: 10) {
                        Text("원가")
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
                    dismiss() // 화면 닫기
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
    }
}
    #Preview {
        NavigationStack {
            AddView()
        }
    
}
