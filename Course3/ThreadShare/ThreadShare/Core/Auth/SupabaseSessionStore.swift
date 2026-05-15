//
//  SupabaseSessionStore.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation
import Combine

protocol SupabaseSessionProviding: AnyObject {
    var session: SupabaseSession? { get }
}

@MainActor
final class SupabaseSessionStore: ObservableObject, SupabaseSessionProviding {
    @Published private(set) var session: SupabaseSession?
    @Published private(set) var isRestoring = true
    @Published private(set) var pendingOnboardingDraft: OnboardingQuestionnaireDraft?
    @Published var errorMessage: String?

    private let authService: SupabaseAuthService
    private let keychainService = "com.tysonpitcher.ThreadShare.supabase.session"
    private let keychainAccount = "session"
    private let hasLaunchedKey = "ThreadShare.hasLaunchedBefore"

    @MainActor
    init(authService: SupabaseAuthService? = nil) {
        self.authService = authService ?? SupabaseAuthService()

        if UserDefaults.standard.bool(forKey: hasLaunchedKey) == false {
            clearStoredSession()
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
        }

        Task { await restoreSession() }
    }

    func restoreSession() async {
        isRestoring = true
        defer { isRestoring = false }

        guard let stored = loadStoredSession() else {
            session = nil
            return
        }

        do {
            let refreshed = try await authService.validateOrRefresh(stored)
            session = refreshed
            try saveSession(refreshed)
        } catch {
            clearStoredSession()
            session = nil
        }
    }

    func signIn(email: String, password: String) async throws {
        let session = try await authService.signIn(email: email, password: password)
        try saveSession(session)
        self.session = session
        pendingOnboardingDraft = nil
    }

    func signUp(
        email: String,
        password: String,
        displayName: String,
        username: String,
        city: String
    ) async throws {
        let session = try await authService.signUp(email: email, password: password)

        try await authService.bootstrapProfile(
            profile: UserProfile(
                id: session.userID,
                displayName: displayName,
                username: username,
                bio: "",
                avatarImageName: "person.crop.circle.fill",
                city: city,
                relationship: .publicUser,
                visibility: .friendsOnly,
                followerCount: 0,
                followingCount: 0,
                styleInterests: [],
                favoriteBrands: [],
                isFollowedByCurrentUser: false
            ),
            email: email,
            session: session
        )

        try saveSession(session)
        self.session = session
        pendingOnboardingDraft = OnboardingQuestionnaireDraft(userID: session.userID, email: email)
    }

    func signOut() async {
        if let session {
            try? await authService.signOut(session)
        }

        clearStoredSession()
        self.session = nil
        pendingOnboardingDraft = nil
    }

    func beginOnboardingDraft(
        styles: [OnboardingStylePreference] = [],
        favoriteBrands: [String] = [],
        usageGoals: [OnboardingUsageGoal] = []
    ) {
        guard let session else { return }
        pendingOnboardingDraft = OnboardingQuestionnaireDraft(
            userID: session.userID,
            email: session.email,
            preferredStyles: styles,
            favoriteBrands: favoriteBrands,
            usageGoals: usageGoals
        )
    }

    func completeOnboarding() {
        pendingOnboardingDraft = nil
    }

    private func saveSession(_ session: SupabaseSession) throws {
        let data = try JSONEncoder.threadShareSupabase.encode(session)
        try KeychainStore.save(data, service: keychainService, account: keychainAccount)
    }

    private func loadStoredSession() -> SupabaseSession? {
        guard let data = try? KeychainStore.load(service: keychainService, account: keychainAccount),
              let session = try? JSONDecoder.threadShareSupabase.decode(SupabaseSession.self, from: data)
        else {
            return nil
        }

        return session
    }

    private func clearStoredSession() {
        KeychainStore.delete(service: keychainService, account: keychainAccount)
    }
}
