//
//  ThreadShareApp.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

@main
struct ThreadShareApp: App {
    @StateObject private var sessionStore = SupabaseSessionStore()

    init() {
        ThreadShareFontRegistrar.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ThreadShareRootView()
                .environmentObject(sessionStore)
        }
    }
}
