import SwiftUI

struct ChatlistView: View {
    
    @State private var goToWishlist = false // 🔹 하트 클릭 이동용
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                Divider()
                    .padding(.top, 10)
                
                ScrollView {
                    LazyVStack(spacing: 40) {
                        ForEach(0..<10) { i in
                            
                            HStack(alignment: .top, spacing: 12) {
                                
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("사용자 \(i)")
                                        .font(.system(size: 16, weight: .bold))
                                    
                                    Text("마지막 메시지입니다.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 6) {
                                    
                                    Text("오후 3:20")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .offset(y: -2)
                                    
                                    Text("3")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("채팅")
                        .font(.system(size: 32, weight: .bold))
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20))
                    }
                }
            }
            
            // 🔹 하단바
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    
                    // 🔹 하트 클릭 -> WishlistView 이동
                    VStack {
                        Button(action: { goToWishlist = true }) {
                            Image(systemName: "heart")
                                .font(.system(size: 24))
                                .padding(3)
                        }
                        Text("좋아요")
                            .font(.system(size: 15))
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "house")
                            .font(.system(size: 24))
                            .padding(3)
                        Text("홈")
                            .font(.system(size: 15))
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "message.fill")
                            .font(.system(size: 24))
                            .padding(3)
                        Text("채팅")
                            .font(.system(size: 15))
                    }
                    
                    Spacer()
                }
                .padding(.top, 10)
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, y: -2)
            }
            
            .fullScreenCover(isPresented: $goToWishlist) {
                            WishlistView()
                                .transition(.move(edge: .leading))
                        }
        }
    }
}

#Preview {
    ChatlistView()
}
