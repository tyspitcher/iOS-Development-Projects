//
//  AuthenticationView.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var sessionStore: SupabaseSessionStore
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        ThreadShareLogoText()

                        Text(viewModel.mode == .signIn ? "Welcome back." : "Create your ThreadShare account.")
                            .font(AppTheme.titleFont(size: 28))
                            .foregroundStyle(AppTheme.ink)

                        Text(viewModel.mode == .signIn ? "Sign in to keep browsing closets, requests, and messages." : "Set up your email login and profile in one step.")
                            .font(AppTheme.bodyFont(size: 15))
                            .foregroundStyle(AppTheme.mutedInk)
                    }

                    if viewModel.mode == .signUp {
                        infoBanner(
                            title: "Email verification is ready later",
                            message: viewModel.emailVerificationNote
                        )
                    }

                    Picker("Mode", selection: $viewModel.mode) {
                        ForEach(AuthViewModel.Mode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(spacing: 14) {
                        field(title: "Email", text: $viewModel.email, keyboard: .emailAddress)
                        field(title: "Password", text: $viewModel.password, keyboard: .default, isSecure: true)

                        Text(viewModel.passwordRequirementSummary)
                            .font(AppTheme.bodyFont(size: 12))
                            .foregroundStyle(AppTheme.mutedInk)

                        if viewModel.mode == .signUp {
                            field(title: "Display Name", text: $viewModel.displayName)
                            field(title: "Username", text: $viewModel.username)
                            field(title: "City", text: $viewModel.city)

                            infoBanner(
                                title: "Onboarding coming next",
                                message: viewModel.onboardingPreview
                            )
                        }
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(AppTheme.bodyFont(size: 13))
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    PrimaryButton(
                        title: viewModel.mode.displayName,
                        systemImage: viewModel.mode == .signIn ? "arrow.right.circle.fill" : "person.badge.plus"
                    ) {
                        Task { await viewModel.submit(using: sessionStore) }
                    }
                    .disabled(!viewModel.canSubmit || viewModel.isSubmitting)

                    if viewModel.isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(AppTheme.pagePadding)
            }
        }
    }


    private func infoBanner(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.bodyFont(size: 13).weight(.semibold))
                .foregroundStyle(AppTheme.ink)

            Text(message)
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func field(title: String, text: Binding<String>, keyboard: UIKeyboardType = .default, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.accent)

            Group {
                if isSecure {
                    SecureField(title, text: text)
                } else {
                    TextField(title, text: text)
                }
            }
            .font(AppTheme.bodyFont(size: 16))
            .keyboardType(keyboard)
            .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
            .autocorrectionDisabled()
            .padding(.horizontal, 14)
            .frame(height: 46)
            .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
    }
}
