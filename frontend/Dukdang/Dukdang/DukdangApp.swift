//
//  DukdangApp.swift
//  Dukdang
//
//  Created by mac15 on 3/23/26.
//

import SwiftUI

@main // (또는 최상단 View)
struct DukdangApp: App {
    // 💡 [핵심] 여기서도 jwtToken을 감시합니다!
    @AppStorage("jwtToken") var jwtToken: String = ""

    var body: some Scene {
        WindowGroup {
            // 토큰이 비어있으면(로그아웃 상태면) 무조건 로그인 화면을 보여주고,
            // 토큰이 있으면(로그인 상태면) 메인 화면을 보여줍니다!
            if jwtToken.isEmpty {
                LoginView()
            } else {
                TabBarView()
            }
        }
    }
}
