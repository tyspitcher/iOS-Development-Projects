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
    init(
        authService: SupabaseAuthService? = nil
    ) {
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
            await markLoginActivity(for: refreshed)
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
        await markLoginActivity(for: session)
    }

    func signUp(
        email: String,
        password: String,
        displayName: String,
        username: String,
        city: String,
        preferenceSelection: FashionPreferenceSelection,
        avatarImageData: Data?,
        avatarFallbackColorHex: String?
    ) async throws {
        let normalizedEmail = email
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let session: SupabaseSession

        do {
            session = try await authService.signUp(email: normalizedEmail, password: password)
        } catch {
            guard authService.isAlreadyRegistered(error) else { throw error }

            // A previous attempt may have created Auth before profile setup failed.
            do {
                let existingSession = try await authService.signIn(email: normalizedEmail, password: password)
                guard try await authService.profileExists(userID: existingSession.userID, session: existingSession) == false else {
                    throw SupabaseAccountCreationError.emailAlreadyRegistered
                }
                session = existingSession
            } catch let accountError as SupabaseAccountCreationError {
                throw accountError
            } catch {
                throw SupabaseAccountCreationError.emailAlreadyRegistered
            }
        }

        let storageService = SupabaseStorageService(sessionProvider: StaticSessionProvider(session: session))
        let initials = AvatarDescriptor.initials(for: displayName, username: username)
        let fallbackColorHex = avatarFallbackColorHex
            ?? AvatarDescriptor.preferredFallbackColorHex(
                for: preferenceSelection.colorPaletteIDs,
                seed: "\(displayName)-\(username)-\(session.userID.uuidString)"
            )

        let avatarPath: String
        if let avatarImageData {
            avatarPath = try await storageService.uploadAvatarImage(
                avatarImageData,
                contentType: "image/jpeg",
                userID: session.userID
            )
        } else {
            avatarPath = AvatarDescriptor.generated(initials: initials, colorHex: fallbackColorHex)
        }

        try await authService.bootstrapProfile(
            profile: UserProfile(
                id: session.userID,
                displayName: displayName,
                username: username,
                bio: "",
                avatarImageName: avatarPath,
                city: city,
                relationship: .publicUser,
                visibility: .friendsOnly,
                followerCount: 0,
                followingCount: 0,
                styleInterests: preferenceSelection.styleIDs,
                favoriteBrands: preferenceSelection.favoriteBrands,
                colorPalettePreferenceIDs: preferenceSelection.colorPaletteIDs,
                isFollowedByCurrentUser: false
            ),
            email: normalizedEmail,
            session: session
        )

        try saveSession(session)
        self.session = session
        await markLoginActivity(for: session)
        pendingOnboardingDraft = OnboardingQuestionnaireDraft(
            userID: session.userID,
            email: normalizedEmail,
            preferredStyleIDs: preferenceSelection.styleIDs,
            favoriteBrands: preferenceSelection.favoriteBrands,
            preferredColorPaletteIDs: preferenceSelection.colorPaletteIDs
        )
    }

    func signOut() async {
        let activeSession = session
        clearStoredSession()
        self.session = nil
        pendingOnboardingDraft = nil

        if let activeSession {
            try? await authService.signOut(activeSession)
        }

    }

    func beginOnboardingDraft(
        styleIDs: [FashionStyle.ID] = [],
        favoriteBrands: [String] = [],
        colorPaletteIDs: [FashionColorPalette.ID] = [],
        usageGoals: [OnboardingUsageGoal] = []
    ) {
        guard let session else { return }
        pendingOnboardingDraft = OnboardingQuestionnaireDraft(
            userID: session.userID,
            email: session.email,
            preferredStyleIDs: styleIDs,
            favoriteBrands: favoriteBrands,
            preferredColorPaletteIDs: colorPaletteIDs,
            usageGoals: usageGoals
        )
    }

    func completeOnboarding() {
        pendingOnboardingDraft = nil
    }

    func requestPasswordReset(email: String) async throws {
        try await authService.requestPasswordReset(email: email.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func markLoginActivity(for session: SupabaseSession) async {
        try? await SupabaseUserActivityService(session: session).markLogin()
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

private final class StaticSessionProvider: SupabaseSessionProviding {
    let session: SupabaseSession?

    init(session: SupabaseSession?) {
        self.session = session
    }
}
