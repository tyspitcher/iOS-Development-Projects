//
//  ThreadShareRootView.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import SwiftUI
import Combine

private enum AppMode {
    static let demoModeStorageKey = "ThreadShare.demoModeEnabled"

    // Demo mode stays behind a debug-only gate so Release/TestFlight keep the live auth flow.
    static var supportsDemoMode: Bool {
#if DEBUG
        true
#else
        false
#endif
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    static let storageKey = "ThreadShare.appearanceMode"

    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            "System"
        case .light:
            "Light"
        case .dark:
            "Dark"
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            nil
        case .light:
            .light
        case .dark:
            .dark
        }
    }
}

struct ThreadShareRootView: View {
    @EnvironmentObject private var sessionStore: SupabaseSessionStore
    @EnvironmentObject private var pushPermissionManager: PushNotificationPermissionManager
    @AppStorage(AppMode.demoModeStorageKey) private var demoModeEnabled = false
    @AppStorage(AppearanceMode.storageKey) private var appearanceModeRaw = AppearanceMode.system.rawValue

    var body: some View {
        Group {
            if AppMode.supportsDemoMode && demoModeEnabled {
                // Demo mode intentionally bypasses auth and remote writes for presentation reliability.
                MainAppContainerView(
                    repository: LocalThreadRepository(),
                    sessionStore: sessionStore,
                    isDemoMode: true,
                    onExitDemoMode: { demoModeEnabled = false }
                )
                .environmentObject(sessionStore)
            } else {
                Group {
                    if sessionStore.isRestoring {
                        restoringView
                    } else if sessionStore.session == nil {
                        AuthenticationView(demoModeEnabled: $demoModeEnabled)
                            .environmentObject(sessionStore)
                    } else {
                        MainAppContainerView(
                            repository: SupabaseThreadRepository(sessionProvider: sessionStore),
                            sessionStore: sessionStore
                        )
                            .environmentObject(sessionStore)
                    }
                }
            }
        }
        .preferredColorScheme(AppearanceMode(rawValue: appearanceModeRaw)?.preferredColorScheme)
        .task {
            await pushPermissionManager.refreshAuthorizationStatus()
        }
        .task(id: sessionStore.session?.userID) {
            if let session = sessionStore.session, let token = PushDeviceTokenStore.currentToken {
                try? await SupabasePushNotificationService(session: session).registerDeviceToken(token)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .threadShareRemoteDeviceTokenDidRegister)) { notification in
            guard
                let token = notification.object as? String,
                let session = sessionStore.session
            else {
                return
            }

            Task {
                try? await SupabasePushNotificationService(session: session).registerDeviceToken(token)
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
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appState: AppState
    @StateObject private var realtimeSyncService: SupabaseRealtimeSyncService
    private let sessionStore: SupabaseSessionStore
    private let isDemoMode: Bool
    private let onExitDemoMode: (() -> Void)?
    
    init(
        repository: ThreadRepository,
        sessionStore: SupabaseSessionStore,
        isDemoMode: Bool = false,
        onExitDemoMode: (() -> Void)? = nil
    ) {
        let appState = AppState(repository: repository)
        _appState = StateObject(wrappedValue: appState)
        _realtimeSyncService = StateObject(
            wrappedValue: SupabaseRealtimeSyncService { [appState] in
                await appState.refreshLiveState()
            }
        )
        self.sessionStore = sessionStore
        self.isDemoMode = isDemoMode
        self.onExitDemoMode = onExitDemoMode
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ContentView()
                .environmentObject(appState)
                .task {
                    if appState.threadItems.isEmpty {
                        await appState.load()
                    }
                    if let pendingNotificationID = PushNotificationRouteStore.pendingNotificationID {
                        appState.handlePushNotificationTap(notificationID: pendingNotificationID)
                        PushNotificationRouteStore.pendingNotificationID = nil
                    }
                    appState.recordUserActivity()
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        appState.recordUserActivity()
                        Task {
                            await appState.refreshLiveState()
                            await realtimeSyncService.synchronize(
                                session: isDemoMode ? nil : sessionStore.session,
                                forceReconnect: true
                            )
                        }
                        if let pendingNotificationID = PushNotificationRouteStore.pendingNotificationID {
                            appState.handlePushNotificationTap(notificationID: pendingNotificationID)
                            PushNotificationRouteStore.pendingNotificationID = nil
                        }
                    }
                }
                .onReceive(Timer.publish(every: 15, on: .main, in: .common).autoconnect()) { _ in
                    Task {
                        await appState.refreshLiveState()
                    }
                }
                .onReceive(Timer.publish(every: 300, on: .main, in: .common).autoconnect()) { _ in
                    appState.recordUserActivity()
                    appState.processDueReturnReminders()
                }
                .onReceive(NotificationCenter.default.publisher(for: .threadSharePushNotificationDidOpen)) { notification in
                    guard let notificationID = notification.object as? UUID else { return }
                    appState.handlePushNotificationTap(notificationID: notificationID)
                }
                .task(id: sessionStore.session?.accessToken) {
                    await realtimeSyncService.synchronize(
                        session: isDemoMode ? nil : sessionStore.session
                    )
                }

            if isDemoMode, let onExitDemoMode {
                Button(action: onExitDemoMode) {
                    Label("Exit Demo", systemImage: "arrow.uturn.backward.circle.fill")
                        .font(AppTheme.bodyFont(size: 13).weight(.semibold))
                        .foregroundStyle(AppTheme.ink)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.thinMaterial, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
        }
    }
}
