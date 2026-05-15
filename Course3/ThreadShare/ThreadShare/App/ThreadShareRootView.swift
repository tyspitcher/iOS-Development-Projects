//
//  ThreadShareRootView.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import SwiftUI

struct ThreadShareRootView: View {
    @EnvironmentObject private var sessionStore: SupabaseSessionStore

    var body: some View {
        Group {
            if sessionStore.isRestoring {
                restoringView
            } else if sessionStore.session == nil {
                AuthenticationView()
                    .environmentObject(sessionStore)
            } else {
                MainAppContainerView(repository: SupabaseThreadRepository(sessionProvider: sessionStore))
                    .environmentObject(sessionStore)
            }
        }
    }

    private var restoringView: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView()
                Text("Opening ThreadShare")
                    .font(AppTheme.bodyFont(size: 15))
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
    }
}

private struct MainAppContainerView: View {
    @EnvironmentObject private var sessionStore: SupabaseSessionStore
    @StateObject private var appState: AppState

    init(repository: ThreadRepository) {
        _appState = StateObject(wrappedValue: AppState(repository: repository))
    }

    var body: some View {
        ContentView()
            .environmentObject(appState)
            .task {
                if appState.threadItems.isEmpty {
                    await appState.load()
                }
            }
    }
}
