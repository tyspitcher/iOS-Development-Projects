//
//  AuthViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode: String, CaseIterable, Identifiable {
        case signIn
        case signUp

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .signIn: "Sign In"
            case .signUp: "Create Account"
            }
        }
    }

    @Published var mode: Mode = .signIn
    @Published var email = ""
    @Published var password = ""
    @Published var displayName = ""
    @Published var username = ""
    @Published var city = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?

    var canSubmit: Bool {
        switch mode {
        case .signIn:
            return isValidEmail(email) && isPasswordValid(password)
        case .signUp:
            return isValidEmail(email) && isPasswordValid(password) && !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var passwordRequirementSummary: String {
        "At least 8 characters with a letter and a number."
    }

    var emailVerificationNote: String {
        "Email verification is off for the demo, but the flow is ready for it later."
    }

    var onboardingPreview: String {
        "Future onboarding can capture style preferences, favorite brands, and app goals without changing this login flow."
    }

    func submit(using sessionStore: SupabaseSessionStore) async {
        guard !isSubmitting else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        errorMessage = nil

        do {
            switch mode {
            case .signIn:
                try await sessionStore.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            case .signUp:
                try await sessionStore.signUp(
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
                    username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                    city: city.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func onboardingDraft(using sessionStore: SupabaseSessionStore) -> OnboardingQuestionnaireDraft? {
        sessionStore.pendingOnboardingDraft
    }

    private func isValidEmail(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && !trimmed.hasPrefix("@") && !trimmed.hasSuffix("@")
    }

    private func isPasswordValid(_ value: String) -> Bool {
        let password = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasMinimumLength = password.count >= 8
        let hasLetter = password.rangeOfCharacter(from: .letters) != nil
        let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
        return hasMinimumLength && hasLetter && hasNumber
    }
}
