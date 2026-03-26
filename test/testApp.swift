//
//  testApp.swift
//  test
//
//  Created by mac00 on 3/25/26.
//

import SwiftUI

@main
struct testApp: App {
    var body: some Scene {
        WindowGroup {
            AuctionContentView(item: .dummyAuction)
        }
    }
}
