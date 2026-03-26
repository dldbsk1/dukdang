import SwiftUI

// MARK: - 더미 데이터

extension Item {
    static let dummy = Item(
        id: UUID(),
        title: "후드 집업",
        description: """
            작년에 구매한 후드 집업입니다.
            사이즈가 맞지 않아 몇 번 입지 않았어요.
            오염이나 손상 없이 깨끗한 상태입니다!
            """,
        price: 15000,
        likeCount: 23,
        status: "판매중",
        imageName: "logo",
        seller: SellerInfo(
            name: "옷장정리중",
            profileImageName: "profile"
        ),
        postTime: "5분 전",
        category: .fashion,
        saleType: .normal,
        auctionEndTime: nil,
        currentBidPrice: nil,
        bidCount: nil
    )
}

// MARK: - 메인 뷰

struct ContentView: View {
    @State private var isGoChat = false
    @Environment(\.dismiss) private var dismiss

    let item: Item

    var body: some View {
        VStack(spacing: 0) {

            NavigationLink(destination: ChatitemView(), isActive: $isGoChat) {
                EmptyView()
            }
            .hidden()

            // ✅ 이미지 + 본문을 하나의 ScrollView로 통합
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: 상단 이미지
                    ZStack(alignment: .topLeading) {
                        if item.imageName.hasPrefix("http") {
                            AsyncImage(url: URL(string: item.imageName)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(height: 300)
                            .clipped()
                        } else {
                            Image(item.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipped()
                        }

                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }
                            Spacer()
                            HStack(spacing: 12) {
                                Image(systemName: "house")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(10)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(10)
                                    .background(Color.black.opacity(0.4))
                                    .clipShape(Circle())
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 55)
                    }

                    // MARK: 본문
                    VStack(alignment: .leading, spacing: 12) {

                        HStack {
                            Image(item.seller.profileImageName)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))

                            VStack(alignment: .leading) {
                                Text(item.seller.name).font(.headline)
                            }
                        }

                        Divider()

                        HStack {
                            Text(item.status)
                                .font(.caption)
                                .padding(6)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }

                        HStack {
                            Text(item.title).font(.title3).bold()
                            Text("\(item.category.rawValue) · \(item.postTime)")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }

                        Text(item.description)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 10)
                            .font(.body)

                        Text("이 게시글 신고하기")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding()
                }
            }

            // MARK: 하단 바 (ScrollView 밖에 고정)
            Divider()
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Button(action: {}) {
                        Image(systemName: "heart").font(.title2)
                    }
                    Text("\(item.likeCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("가격")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(item.price.wonFormatted)
                        .font(.title2)
                        .bold()
                }
                Spacer()
                Button(action: { isGoChat = true }) {
                    Text("채팅 하기")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - 프리뷰

#Preview {
    NavigationStack {
        ContentView(item: .dummy)
    }
}
