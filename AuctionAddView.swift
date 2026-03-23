//
//  AuctionAddView.swift
//  Dukdang
//
//  Created by mac16 on 3/19/26.
//

import SwiftUI

struct AuctionAddView: View {
    @Environment(\.dismiss) private var dismiss // 전으로 돌아가기
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startingPrice: String = "" // 시작가
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
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                    .padding(.top, 10)
                    
                    Divider()
                    
                    // 제목
                    VStack(alignment: .leading, spacing: 10) {
                        Text("제목")
                            .font(.system(size: 16, weight: .bold)) // 진한 글씨
                        TextField("경매 물품 제목을 입력해주세요", text: $title)
                            .font(.system(size: 16))
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("자세한 설명")
                            .font(.system(size: 16, weight: .bold))
                        
                        ZStack(alignment: .topLeading) {
                            // 힌트 글자 (내용이 비어있을 때만 보임)
                            if description.isEmpty {
                                Text("경매 물품에 대한 자세한 설명을 적어주세요.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16) // 커서 위치와 맞게 조절
                                    .padding(.vertical, 16)
                            }
                            
                            // 입력창
                            TextEditor(text: $description)
                                .font(.system(size: 15))
                                .frame(minHeight: 150)
                                .padding(8)
                                // !!!핵심: TextEditor의 기본 하얀 배경을 투명하게 만듦
                                .scrollContentBackground(.hidden)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Divider()
                    
                    // 시작가
                    VStack(alignment: .leading, spacing: 10) {
                        Text("시작가")
                            .font(.system(size: 16, weight: .bold)) // 진한 글씨
                        HStack {
                            Text("₩").foregroundColor(.black)
                            TextField("경매를 시작할 가격을 입력해주세요", text: $startingPrice)
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    Divider()
                    
                    // 위치
                    VStack(alignment: .leading, spacing: 10) {
                        Text("위치")
                            .font(.system(size: 16, weight: .bold)) // 진한 글씨
                        HStack(spacing: 5) {
                            Text("#")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.red)
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
                        .background(Color.red)
                        .cornerRadius(12)
                        .padding()
                }
            }
            .background(Color.white)
        }
        .navigationTitle("경매 물건 올리기") // 상단 탭 이름
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AuctionAddView()
    }
}
