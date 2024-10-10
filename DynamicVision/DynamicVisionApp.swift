//
//  DynamicVisionApp.swift
//  DynamicVision
//
//  Created by 佐藤咲祐 on 2024/01/23.
//

import SwiftUI

@main
struct DynamicVisionApp: App {
    @State private var spinSpeed = 0.1 // 初期値は0.1秒

    var body: some Scene {
        WindowGroup {
            NavigationView {
                HomeView(spinSpeed: $spinSpeed)
            }
        }
    }
}
