//
//  AuthenticationView.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AuthenticationView: View {
    @EnvironmentObject private var sessionStore: SupabaseSessionStore
    @Binding var demoModeEnabled: Bool
    @StateObject private var viewModel = AuthViewModel()
    @State private var isShowingForgotPasswordAlert = false
    @State private var isShowingPassword = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: FieldKind?

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                        VStack(alignment: .leading, spacing: AppTheme.compactSpacing) {
                            ThreadShareLogoText()

                            Text(viewModel.mode == .signIn ? "Welcome back." : "Create your ThreadShare account.")
                                .font(AppTheme.titleFont(size: 30))
                                .foregroundStyle(AppTheme.ink)

                            Text(viewModel.mode == .signIn ? "Sign in to open your own closet, requests, and messages." : "Create a login and profile so ThreadShare feels like yours from the start.")
                                .font(AppTheme.bodyFont(size: 15))
                                .foregroundStyle(AppTheme.mutedInk)
                        }

                        Picker("Mode", selection: $viewModel.mode) {
                            ForEach(AuthViewModel.Mode.allCases) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .accessibilityLabel("Authentication Mode")
                        .accessibilityHint("Switch between signing in and creating a new account.")

                        if viewModel.mode == .signIn {
                            signInCard
                        } else {
                            SignUpOnboardingPagerView(
                                email: $viewModel.email,
                                password: $viewModel.password,
                                displayName: $viewModel.displayName,
                                username: $viewModel.username,
                                city: $viewModel.city,
                                preferenceSelection: $viewModel.preferenceSelection,
                                customBrandEntry: $viewModel.customBrandEntry,
                                avatarImageData: $viewModel.avatarImageData,
                                avatarFallbackColorHex: $viewModel.avatarFallbackColorHex,
                                onboardingPreview: viewModel.onboardingPreview,
                                emailVerificationNote: viewModel.emailVerificationNote,
                                canSubmit: viewModel.canSubmit,
                                isSubmitting: viewModel.isSubmitting,
                                submitAction: {
                                    Task { await viewModel.submit(using: sessionStore) }
                                }
                            )
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(AppTheme.bodyFont(size: 13, weight: .medium))
                                .foregroundStyle(.red)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel("Error: \(errorMessage)")
                        }

                        if viewModel.isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        }

#if DEBUG
                        demoModeCard
#endif
                    }
                    .padding(AppTheme.pagePadding)
                    .padding(.bottom, max(160, keyboardHeight + 140))
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, field in
                    guard let field else { return }
                    withAnimation(.easeInOut(duration: 0.22)) {
                        proxy.scrollTo(field, anchor: .center)
                    }
                }
                .onChange(of: viewModel.mode) { _, _ in
                    viewModel.clearErrorMessage()
                }
                .onChange(of: viewModel.email) { _, _ in
                    viewModel.clearErrorMessage()
                }
                .onChange(of: viewModel.password) { _, _ in
                    viewModel.clearErrorMessage()
                }
                .onChange(of: viewModel.displayName) { _, _ in
                    viewModel.clearErrorMessage()
                }
                .onChange(of: viewModel.username) { _, _ in
                    viewModel.clearErrorMessage()
                }
                .onChange(of: viewModel.city) { _, _ in
                    viewModel.clearErrorMessage()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                    withAnimation(.easeInOut(duration: 0.22)) {
                        keyboardHeight = frame.height
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    withAnimation(.easeInOut(duration: 0.22)) {
                        keyboardHeight = 0
                    }
                }
            }
        }
        .alert("Password Reset", isPresented: $isShowingForgotPasswordAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.forgotPasswordMessage ?? "We sent password reset instructions if the email address is registered.")
        }
    }

    #if DEBUG
    private var demoModeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $demoModeEnabled) {
                VStack(alignment: .leading, spacing: AppTheme.microSpacing) {
                    Text("Demo mode")
                        .font(AppTheme.bodyFont(size: 14, weight: .semibold))
                        .foregroundStyle(AppTheme.ink)

                    Text("Use the sample closet for presentations.")
                        .font(AppTheme.bodyFont(size: 13))
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: AppTheme.accent))
            .accessibilityLabel("Demo Mode")
            .accessibilityHint("When on, opens a sample experience and bypasses normal sign in.")

            Text("Turn this off anytime to return to the Supabase login flow.")
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.mutedInk)
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }
    #endif


    private var signInCard: some View {
        VStack(spacing: AppTheme.tightSpacing) {
            field(
                title: "Email",
                text: $viewModel.email,
                kind: .email
            )
            field(
                title: "Password",
                text: $viewModel.password,
                kind: .password
            )

            Button {
                Task {
                    await viewModel.handleForgotPasswordTapped(using: sessionStore)
                    isShowingForgotPasswordAlert = true
                }
            } label: {
                Text("Forgot password?")
                    .font(AppTheme.bodyFont(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .frame(minHeight: 44, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Shows the password reset status and next steps.")

            Text(viewModel.passwordRequirementSummary)
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.mutedInk)

            PrimaryButton(
                title: viewModel.mode.displayName,
                systemImage: "arrow.right.circle.fill"
            ) {
                Task { await viewModel.submit(using: sessionStore) }
            }
            .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
            .accessibilityHint("Attempts to sign in with your email and password.")
        }
        .padding(AppTheme.cardPadding)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func field(
        title: String,
        text: Binding<String>,
        kind: FieldKind = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.xSmallSpacing) {
            Text(title)
                .font(AppTheme.bodyFont(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.accent)

            Group {
                if kind == .password {
                    HStack(spacing: 8) {
                        Group {
                            if isShowingPassword {
                                TextField(title, text: text)
                            } else {
                                SecureField(title, text: text)
                            }
                        }
                        .modifier(AuthFieldInputStyle(kind: kind))
                        .focused($focusedField, equals: kind)

                        Button {
                            isShowingPassword.toggle()
                        } label: {
                            Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                                .font(AppTheme.captionFont(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.mutedInk)
                                .frame(width: 34, height: 34)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isShowingPassword ? "Hide password" : "Show password")
                    }
                } else {
                    TextField(title, text: text)
                        .modifier(AuthFieldInputStyle(kind: kind))
                        .focused($focusedField, equals: kind)
                }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 46)
            .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .accessibilityLabel(title)
            .id(kind)
        }
    }
}

private extension AuthenticationView {
    enum FieldKind: Hashable {
        case `default`
        case email
        case password
    }
}

private struct AuthFieldInputStyle: ViewModifier {
    let kind: AuthenticationView.FieldKind

    @ViewBuilder
    func body(content: Content) -> some View {
        switch kind {
        case .email:
            content
                .font(AppTheme.bodyFont(size: 16))
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        case .password:
            content
                .font(AppTheme.bodyFont(size: 16))
                .keyboardType(.default)
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        case .default:
            content
                .font(AppTheme.bodyFont(size: 16))
                .keyboardType(.default)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
        }
    }
}
