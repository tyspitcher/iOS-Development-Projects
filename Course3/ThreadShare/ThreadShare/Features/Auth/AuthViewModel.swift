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
    @Published var preferenceSelection = FashionPreferenceSelection()
    @Published var customBrandEntry = ""
    @Published var avatarImageData: Data?
    @Published var avatarFallbackColorHex: String?
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var forgotPasswordMessage: String?

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
        "If verification is required, check your inbox for the link to finish setting up your account."
    }

    var onboardingPreview: String {
        "Pick a few styles, brands, and color palettes now so your profile starts with real preferences."
    }

    var suggestedBrandNames: [String] {
        preferenceSelection.suggestedBrandNames
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
                    city: city.trimmingCharacters(in: .whitespacesAndNewlines),
                    preferenceSelection: preferenceSelection,
                    avatarImageData: avatarImageData,
                    avatarFallbackColorHex: avatarFallbackColorHex
                )
            }
        } catch {
            errorMessage = userFacingMessage(for: error)
        }
    }

    func onboardingDraft(using sessionStore: SupabaseSessionStore) -> OnboardingQuestionnaireDraft? {
        sessionStore.pendingOnboardingDraft
    }

    func toggleStyle(_ styleID: FashionStyle.ID) {
        preferenceSelection.toggleStyle(styleID)
    }

    func toggleBrand(_ brandName: String) {
        preferenceSelection.toggleBrand(brandName)
    }

    func toggleColorPalette(_ paletteID: FashionColorPalette.ID) {
        preferenceSelection.toggleColorPalette(paletteID)
    }

    func addCustomBrand() {
        let value = customBrandEntry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.isEmpty == false else { return }
        preferenceSelection.addCustomBrand(value)
        customBrandEntry = ""
    }

    func removeBrand(_ brandName: String) {
        preferenceSelection.removeBrand(brandName)
    }

    func handleForgotPasswordTapped(using sessionStore: SupabaseSessionStore) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedEmail.isEmpty == false else {
            forgotPasswordMessage = "Enter your account email to continue."
            return
        }

        do {
            try await sessionStore.requestPasswordReset(email: trimmedEmail)
            forgotPasswordMessage = "If an account exists for \(trimmedEmail), a password reset email has been sent."
        } catch {
            forgotPasswordMessage = "We couldn't send the password reset email right now. Please try again in a moment."
        }
    }

    func clearErrorMessage() {
        errorMessage = nil
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

    private func userFacingMessage(for error: Error) -> String {
        let nsError = error as NSError
        let message = nsError.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)

        if mode == .signIn {
            if message.isEmpty == false {
                if message.localizedCaseInsensitiveContains("invalid login credentials") {
                    return "Incorrect email or password. Please try again."
                }
                if message.localizedCaseInsensitiveContains("email not confirmed") {
                    return "Please confirm your email before signing in."
                }
                return message
            }

            return "Unable to sign in right now. Please try again."
        }

        if error is SupabaseAccountCreationError {
            return message
        }

        return "We couldn't finish creating your account. Please try again. If this keeps happening, contact support."
    }
}
