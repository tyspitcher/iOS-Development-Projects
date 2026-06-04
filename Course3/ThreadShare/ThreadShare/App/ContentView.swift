//
//  ContentView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

private enum AppTab: Hashable {
    case discover
    case borrow
    case profile
}

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: AppTab = .discover
    @State private var deepLinkedItem: ThreadItem?
    @State private var deepLinkedDMOwner: UserProfile?
    @State private var deepLinkedDMItem: ThreadItem?
    @State private var isShowingNotificationCenter = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoverView()
                .tag(AppTab.discover)
                .tabItem {
                    Label("Discover", systemImage: "sparkles.rectangle.stack")
                }

            BorrowView()
                .tag(AppTab.borrow)
                .tabItem {
                    Label("Borrow", systemImage: "tshirt.fill")
                }

            ProfileView()
                .tag(AppTab.profile)
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .tint(AppTheme.accent)
        .task {
            if appState.threadItems.isEmpty {
                await appState.load()
            }
        }
        .onChange(of: appState.pendingDeepLinkTarget) { _, newTarget in
            guard let newTarget else { return }
            routeToDeepLink(newTarget)
            appState.clearPendingDeepLinkTarget()
        }
        .sheet(item: $deepLinkedItem) { item in
            NavigationStack {
                ThreadItemDetailView(item: item)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                deepLinkedItem = nil
                            }
                            .font(AppTheme.bodyFont(size: 14, weight: .semibold))
                        }
                    }
            }
        }
        .sheet(isPresented: $isShowingNotificationCenter) {
            NavigationStack {
                NotificationCenterView()
                    .environmentObject(appState)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                isShowingNotificationCenter = false
                            }
                            .font(AppTheme.bodyFont(size: 14, weight: .semibold))
                        }
                    }
            }
        }
        .sheet(item: $deepLinkedDMOwner) { owner in
            NavigationStack {
                DMChatView(owner: owner, item: deepLinkedDMItem)
                    .environmentObject(appState)
            }
        }
    }

    private func routeToDeepLink(_ target: AppDeepLinkTarget) {
        isShowingNotificationCenter = false
        deepLinkedItem = nil
        deepLinkedDMOwner = nil
        deepLinkedDMItem = nil

        switch target {
        case let .discoverItem(itemID):
            selectedTab = .discover
            if let item = appState.threadItems.first(where: { $0.id == itemID }) {
                deepLinkedItem = item
            } else {
                selectedTab = .profile
                isShowingNotificationCenter = true
            }
        case .borrowBoard:
            selectedTab = .borrow
        case let .directMessage(userID, itemID):
            selectedTab = .profile
            if let owner = appState.users.first(where: { $0.id == userID }) {
                deepLinkedDMOwner = owner
                deepLinkedDMItem = itemID.flatMap { linkedItemID in
                    appState.threadItems.first(where: { $0.id == linkedItemID })
                }
            } else {
                isShowingNotificationCenter = true
            }
        case .notificationCenter:
            selectedTab = .profile
            isShowingNotificationCenter = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
