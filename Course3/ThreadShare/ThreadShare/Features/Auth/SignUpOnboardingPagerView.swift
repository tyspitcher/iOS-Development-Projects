//
//  SignUpOnboardingPagerView.swift
//  ThreadShare
//
//  Created by Codex on 5/23/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct SignUpOnboardingPagerView: View {
    private enum ScrollAnchor: Hashable {
        case top
    }

    @Binding var email: String
    @Binding var password: String
    @Binding var displayName: String
    @Binding var username: String
    @Binding var city: String
    @Binding var preferenceSelection: FashionPreferenceSelection
    @Binding var customBrandEntry: String
    @Binding var avatarImageData: Data?
    @Binding var avatarFallbackColorHex: String?

    let onboardingPreview: String
    let emailVerificationNote: String
    let canSubmit: Bool
    let isSubmitting: Bool
    let submitAction: () -> Void

    @State private var pageIndex = 0
    @State private var activeAvatarErrorMessage: String?
    @State private var isShowingPassword = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var focusedField: FieldKind?

    private let pageCount = 4

    private var requiredBasicsAreComplete: Bool {
        canSubmit
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Color.clear
                        .frame(height: 1)
                        .id(ScrollAnchor.top)

                    pagerHeader
                    currentPage
                    pagerControls

                    Color.clear
                        .frame(height: max(140, keyboardHeight + 40))
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .onAppear {
                pageIndex = 0
            }
            .onDisappear {
                pageIndex = 0
            }
            .onChange(of: pageIndex) { _, _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(ScrollAnchor.top, anchor: .top)
                }
            }
            .onChange(of: focusedField) { _, field in
                guard let field else { return }
                withAnimation(.easeInOut(duration: 0.22)) {
                    proxy.scrollTo(field, anchor: .center)
                }
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
            .alert("Profile Photo", isPresented: Binding(
                get: { activeAvatarErrorMessage != nil },
                set: { if $0 == false { activeAvatarErrorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    activeAvatarErrorMessage = nil
                }
            } message: {
                Text(activeAvatarErrorMessage ?? "We couldn't load that profile photo.")
            }
        }
    }

    private var pagerHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Create Account")
                        .font(AppTheme.titleFont(size: 24))
                        .foregroundStyle(AppTheme.ink)

                    Text("A few quick pages to personalize your profile.")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.mutedInk)
                }

                Spacer()

                Text("\(pageIndex + 1) / \(pageCount)")
                    .font(AppTheme.bodyFont(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.background, in: Capsule())
                    .overlay(Capsule().stroke(AppTheme.border, lineWidth: 1))
            }

            pageDots
        }
    }

    private var pageDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(index == pageIndex ? AppTheme.accent : AppTheme.border)
                    .frame(width: index == pageIndex ? 22 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: pageIndex)
            }
        }
    }

    @ViewBuilder
    private var currentPage: some View {
        switch pageIndex {
        case 0:
            basicsPage
        case 1:
            stylePage
        case 2:
            brandPage
        default:
            avatarPage
        }
    }

    private var basicsPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            infoBanner(title: "Email verification", message: emailVerificationNote)
            Text("Fields marked with * are required. City is optional.")
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            signUpField(
                title: "Email",
                text: $email,
                kind: .email,
                isRequired: true
            )

            signUpField(
                title: "Password",
                text: $password,
                kind: .password,
                isRequired: true
            )

            signUpField(title: "Display Name", text: $displayName, kind: .name, isRequired: true)
            signUpField(
                title: "Username",
                text: $username,
                kind: .username,
                isRequired: true
            )
            signUpField(title: "City", text: $city, kind: .city)

            Text(onboardingPreview)
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var stylePage: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(
                title: "Style Interests",
                subtitle: "Pick the looks you naturally reach for most."
            )

            chipWrap(values: FashionPreferenceCatalog.styles.map(\.id)) { styleID in
                SelectablePreferenceChip(
                    title: FashionPreferenceCatalog.displayName(forStyleID: styleID),
                    isSelected: preferenceSelection.styleIDs.contains(styleID)
                ) {
                    preferenceSelection.toggleStyle(styleID)
                }
            }
        }
    }

    private var brandPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(
                title: "Favorite Brands",
                subtitle: "Suggested brands update from your selected styles. Add your own too."
            )

            if preferenceSelection.favoriteBrands.isEmpty == false {
                chipWrap(values: preferenceSelection.favoriteBrands) { brand in
                    RemovablePreferenceChip(title: brand) {
                        preferenceSelection.removeBrand(brand)
                    }
                }
            }

            if preferenceSelection.suggestedBrandNames.isEmpty == false {
                chipWrap(values: preferenceSelection.suggestedBrandNames) { brand in
                    SelectablePreferenceChip(
                        title: brand,
                        isSelected: preferenceSelection.favoriteBrands.contains(brand)
                    ) {
                        preferenceSelection.toggleBrand(brand)
                    }
                }
            } else {
                Text("Choose at least one style to unlock brand suggestions.")
                    .font(AppTheme.bodyFont(size: 13))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            HStack(spacing: 10) {
                TextField("Add custom brand", text: $customBrandEntry)
                    .font(AppTheme.bodyFont(size: 15))
                    .textInputAutocapitalization(.words)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .onSubmit(addCustomBrand)
                    .accessibilityLabel("Add custom brand")
                    .focused($focusedField, equals: .customBrand)
                    .id(FieldKind.customBrand)

                Button("Add", action: addCustomBrand)
                    .font(AppTheme.bodyFont(size: 14, weight: .semibold))
                    .foregroundStyle(customBrandEntry.trimmed.isEmpty ? AppTheme.softInk : AppTheme.ink)
                    .frame(width: 64, height: 44)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .disabled(customBrandEntry.trimmed.isEmpty)
            }
        }
    }

    private var avatarPage: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(
                title: "Profile Photo",
                subtitle: "Pick a photo now, or let ThreadShare build a colorful initials avatar for you."
            )

            avatarPreviewCard

            ProfilePhotoSourcePicker(
                previewImageData: avatarImageData,
                onLibraryImageData: handleAvatarLibraryImageData,
                onCameraImageData: handleAvatarCameraImageData,
                onError: handleAvatarError
            )

            if avatarImageData != nil {
                Button("Use generated avatar") {
                    avatarImageData = nil
                }
                .font(AppTheme.bodyFont(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(minHeight: 44, alignment: .leading)
                .buttonStyle(.plain)
            }

            sectionHeading(
                title: "Fallback Color",
                subtitle: "If you skip a photo, we’ll use your initials with one of these colors."
            )

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: 10)], spacing: 10) {
                ForEach(avatarColorHexes, id: \.self) { hex in
                    avatarColorSwatch(hex: hex)
                }
            }

            Button("Random color") {
                avatarFallbackColorHex = avatarColorHexes.randomElement()
            }
            .font(AppTheme.bodyFont(size: 13, weight: .semibold))
            .foregroundStyle(AppTheme.accent)
            .buttonStyle(.plain)

            Text("Your chosen color palettes help us suggest a good fallback if you skip this step.")
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            if let selectedFallbackColorHex {
                Text("Selected color: #\(selectedFallbackColorHex)")
                    .font(AppTheme.bodyFont(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.softInk)
            }
        }
    }

    private var pagerControls: some View {
        HStack(spacing: 10) {
            Button {
                withAnimation(.easeInOut) {
                    pageIndex = max(0, pageIndex - 1)
                }
            } label: {
                Text("Back")
                    .font(AppTheme.bodyFont(size: 15, weight: .semibold))
                    .foregroundStyle(pageIndex == 0 ? AppTheme.softInk : AppTheme.ink)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(pageIndex == 0)

            Button {
                if pageIndex == pageCount - 1 {
                    submitAction()
                } else {
                    withAnimation(.easeInOut) {
                        pageIndex = min(pageCount - 1, pageIndex + 1)
                    }
                }
            } label: {
                Text(pageIndex == pageCount - 1 ? "Create Account" : "Next")
                    .font(AppTheme.bodyFont(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(nextButtonBackground, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(nextButtonDisabled)
            .accessibilityHint(nextButtonAccessibilityHint)
        }
    }

    private func addCustomBrand() {
        let value = customBrandEntry.trimmed
        guard value.isEmpty == false else { return }
        preferenceSelection.addCustomBrand(value)
        customBrandEntry = ""
    }

    private func signUpField(
        title: String,
        text: Binding<String>,
        kind: FieldKind = .default,
        isRequired: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(title)
                    .font(AppTheme.bodyFont(size: 13))
                    .foregroundStyle(AppTheme.accent)

                if isRequired {
                    Text("*")
                        .font(AppTheme.bodyFont(size: 13, weight: .semibold))
                        .foregroundStyle(.red)
                        .accessibilityHidden(true)
                } else {
                        Text("Optional")
                            .font(AppTheme.bodyFont(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.softInk)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.background, in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                        .accessibilityHidden(true)
                }
            }

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
                        .modifier(SignUpFieldInputStyle(kind: kind))
                        .focused($focusedField, equals: kind)

                        Button {
                            isShowingPassword.toggle()
                        } label: {
                            Image(systemName: isShowingPassword ? "eye.slash.fill" : "eye.fill")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(AppTheme.mutedInk)
                                .frame(width: 34, height: 34)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isShowingPassword ? "Hide password" : "Show password")
                    }
                } else {
                    TextField(title, text: text)
                        .modifier(SignUpFieldInputStyle(kind: kind))
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
            .id(kind)
        }
    }

    private var nextButtonBackground: Color {
        if pageIndex == pageCount - 1 {
            return canSubmit && !isSubmitting ? AppTheme.accent : AppTheme.softInk
        }

        if pageIndex == 0 {
            return requiredBasicsAreComplete ? AppTheme.accent : AppTheme.softInk
        }

        return AppTheme.accent
    }

    private var nextButtonDisabled: Bool {
        if pageIndex == pageCount - 1 {
            return !canSubmit || isSubmitting
        }

        if pageIndex == 0 {
            return !requiredBasicsAreComplete
        }

        return false
    }

    private var nextButtonAccessibilityHint: String {
        if pageIndex == 0 && !requiredBasicsAreComplete {
            return "Fill in email, password, display name, and username to continue."
        }

        if pageIndex == pageCount - 1 {
            return "Creates your account."
        }

        return "Moves to the next onboarding page."
    }

    private func infoBanner(title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.bodyFont(size: 13, weight: .semibold))
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
        .accessibilityElement(children: .combine)
    }

    private func sectionHeading(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.accent)
                .textCase(.uppercase)

            Text(subtitle)
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func chipWrap<Value: Hashable, Content: View>(
        values: [Value],
        @ViewBuilder content: @escaping (Value) -> Content
    ) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 130), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(values, id: \.self) { value in
                content(value)
            }
        }
    }

    private var avatarPreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 14) {
                if let avatarImageData {
                    DataBackedImageView(data: avatarImageData, contentMode: .fill)
                        .frame(width: 108, height: 108)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                } else {
                    UserAvatarView(imageName: previewAvatarDescriptor, size: 108)
                        .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(previewAvatarMessage)
                        .font(AppTheme.bodyFont(size: 13))
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("You can always change this later in your profile settings.")
                        .font(AppTheme.bodyFont(size: 12))
                        .foregroundStyle(AppTheme.softInk)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
        }
    }

    private func avatarColorSwatch(hex: String) -> some View {
        let isSelected = selectedFallbackColorHex == normalizedHex(hex)

        return Button {
            avatarFallbackColorHex = normalizedHex(hex)
        } label: {
            Circle()
                .fill(Color(threadShareHex: hex))
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .stroke(isSelected ? AppTheme.ink : AppTheme.border, lineWidth: isSelected ? 3 : 1)
                )
                .overlay(
                    Group {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(AvatarDescriptor.contrastColor(for: hex))
                        }
                    }
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Avatar color \(hex)")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
    }

    private var avatarColorHexes: [String] {
        let paletteHexes = FashionPreferenceCatalog.avatarColorHexes(forPaletteIDs: preferenceSelection.colorPaletteIDs)
        if paletteHexes.isEmpty == false {
            return Array(paletteHexes.prefix(8))
        }
        return AvatarDescriptor.fallbackColorHexes(for: [])
    }

    private var selectedFallbackColorHex: String? {
        avatarFallbackColorHex.map(normalizedHex)
    }

    private var previewAvatarDescriptor: String {
        AvatarDescriptor.generated(
            initials: AvatarDescriptor.initials(for: displayName, username: username),
            colorHex: selectedFallbackColorHex ?? AvatarDescriptor.preferredFallbackColorHex(
                for: preferenceSelection.colorPaletteIDs,
                seed: "\(displayName)-\(username)"
            )
        )
    }

    private var previewAvatarMessage: String {
        if avatarImageData != nil {
            return "Photo selected. This will be your profile image when you create the account."
        }

        return "No photo selected. We’ll use your initials and the chosen fallback color."
    }

    private func handleAvatarLibraryImageData(_ data: Data) {
        avatarImageData = data
    }

    private func handleAvatarCameraImageData(_ data: Data) {
        avatarImageData = data
    }

    private func handleAvatarError(_ message: String) {
        activeAvatarErrorMessage = message
    }

    private func normalizedHex(_ value: String) -> String {
        let cleaned = value.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).uppercased()
        return cleaned.count >= 6 ? String(cleaned.prefix(6)) : cleaned
    }

}

private extension SignUpOnboardingPagerView {
    enum FieldKind: Hashable {
        case `default`
        case email
        case password
        case name
        case username
        case city
        case customBrand
    }

}

private struct SignUpFieldInputStyle: ViewModifier {
    let kind: SignUpOnboardingPagerView.FieldKind

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
        case .name:
            content
                .font(AppTheme.bodyFont(size: 16))
                .keyboardType(.default)
                .textContentType(.name)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
        case .username:
            content
                .font(AppTheme.bodyFont(size: 16))
                .keyboardType(.default)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        case .city:
            content
                .font(AppTheme.bodyFont(size: 16))
                .keyboardType(.default)
                .textContentType(.addressCity)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
        case .customBrand:
            content
                .font(AppTheme.bodyFont(size: 16))
                .keyboardType(.default)
                .textInputAutocapitalization(.words)
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
