//
//  AuctionAddView.swift
//  Dukdang
//
//  Created by mac16 on 3/19/26.
//

import SwiftUI

struct AuctionAddView: View {
    @Environment(\.dismiss) private var dismiss
    
    // TradePostItem 구조체 및 경매 로직에 필요한 상태 변수들
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var startingPrice: String = ""
    @State private var auctionEndTime: Date = Date().addingTimeInterval(3600 * 24) // 기본값: 현재로부터 24시간 후
    
    // 모든 필수 필드가 채워졌는지 확인 (시간은 기본값이 있으므로 제목, 설명, 가격 체크)
    private var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && !startingPrice.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 1. 이미지 선택
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
                    
                    // 2. 제목 입력
                    VStack(alignment: .leading, spacing: 10) {
                        Text("제목")
                            .font(.system(size: 16, weight: .bold))
                        TextField("경매 물품 제목을 입력해주세요", text: $title)
                            .font(.system(size: 16))
                    }
                    
                    Divider()
                    
                    // 3. 시작가 입력
                    VStack(alignment: .leading, spacing: 10) {
                        Text("경매 시작가")
                            .font(.system(size: 16, weight: .bold))
                        HStack {
                            Text("₩").bold()
                            TextField("가격을 입력해주세요", text: $startingPrice)
                                .keyboardType(.numberPad)
                        }
                    }
                    
                    Divider()
                    
                    // 4. 마감 시간 설정
                    VStack(alignment: .leading, spacing: 10) {
                        Text("경매 마감 시간")
                            .font(.system(size: 16, weight: .bold))
                        
                        DatePicker(
                            "마감 날짜 및 시간",
                            selection: $auctionEndTime,
                            in: Date()..., // 현재 시간 이전은 선택 불가
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact) // 다이얼 및 캘린더 형태의 컴팩트 스타일
                        .labelsHidden() // 레이블 숨기고 다이얼만 강조
                    }
                    
                    Divider()
                    
                    // 5. 상세 설명
                    VStack(alignment: .leading, spacing: 10) {
                        Text("자세한 설명")
                            .font(.system(size: 16, weight: .bold))
                        
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("경매 물품에 대한 자세한 설명을 적어주세요.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 8)
                            }
                            
                            TextEditor(text: $description)
                                .font(.system(size: 15))
                                .frame(minHeight: 150)
                                .scrollContentBackground(.hidden)
                        }
                    }
                }
                .padding(20)
            }
            
            // 작성 완료 버튼 영역
            VStack {
                Divider()
                Button(action: {
                    if isFormValid {
                        // TODO: 여기서 TradePostItem 생성 로직 수행
                        // auctionEndTime을 ISO8601 문자열로 변환하여 전달
                        dismiss()
                    }
                }) {
                    Text("경매 등록하기")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        // 버튼 배경색 변경
                        .background(isFormValid ? Color.red : Color.gray)
                        .cornerRadius(12)
                        .padding()
                }
                .disabled(!isFormValid)
            }
            .background(Color.white)
        }
        .navigationTitle("경매 물건 올리기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AuctionAddView()
    }
}
