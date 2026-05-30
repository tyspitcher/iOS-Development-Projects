//
//  SettingsView.swift
//  ThreadShare
//
//  Created by Codex on 5/22/26.
//

import SwiftUI

private enum SettingsAlert: Identifiable {
    case deletionRequested
    case deletionCanceled
    case immediateDeletionRecorded

    var id: String {
        switch self {
        case .deletionRequested:
            "deletion-requested"
        case .deletionCanceled:
            "deletion-canceled"
        case .immediateDeletionRecorded:
            "immediate-deletion-recorded"
        }
    }

    var title: String {
        switch self {
        case .deletionRequested:
            "Deletion Requested"
        case .deletionCanceled:
            "Deletion Canceled"
        case .immediateDeletionRecorded:
            "Immediate Deletion Needs Backend Support"
        }
    }

    var message: String {
        switch self {
        case .deletionRequested:
            "Your account deletion request is pending. You can cancel it from Settings during the 14-day grace period."
        case .deletionCanceled:
            "Your pending account deletion request has been canceled."
        case .immediateDeletionRecorded:
            "Your immediate deletion confirmation was recorded, but this build cannot permanently delete your account from the client. Your account remains active until a trusted server-side deletion function is implemented."
        }
    }
}

struct SettingsView: View {
    private static let immediateDeletionConfirmationCopy = "I understand I am permanently deleting my account immediately and that I will not be able to recover my data."

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var sessionStore: SupabaseSessionStore
    @AppStorage(AppearanceMode.storageKey) private var appearanceModeRaw = AppearanceMode.system.rawValue
    @State private var activeAlert: SettingsAlert?
    @State private var isShowingDeletionRequestConfirmation = false
    @State private var isShowingDeletionCancelConfirmation = false
    @State private var isShowingImmediateDeletionConfirmation = false
    @State private var isLoggingOut = false
    private let supportEmail = "tyspitcher@gmail.com"
    private let inviteMessage = "Join me on ThreadShare to swap closet pieces and discover style ideas."

    private var currentUser: UserProfile? {
        appState.currentUser
    }

    private var appearanceSelection: Binding<AppearanceMode> {
        Binding(
            get: {
                AppearanceMode(rawValue: appearanceModeRaw) ?? .system
            },
            set: { appearanceModeRaw = $0.rawValue }
        )
    }

    var body: some View {
        Form {
            accountSection
#if DEBUG
            developerActivitySection
#endif
            appearanceSection
            preferencesSection
            socialSection
            supportSection
            legalSection
            sessionSection
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await appState.loadPendingAccountDeletionRequest() }
        }
        .onChange(of: currentUser?.id) { _, userID in
            guard userID != nil else { return }
            Task { await appState.loadPendingAccountDeletionRequest() }
        }
        .alert("Request account deletion?", isPresented: $isShowingDeletionRequestConfirmation) {
            Button("Keep Account", role: .cancel) {}
            Button("Request Deletion", role: .destructive) {
                requestAccountDeletion()
            }
        } message: {
            Text("This starts a 14-day grace period. Your account is not deleted immediately, and you can cancel the request from Settings before the scheduled deletion date.")
        }
        .alert("Cancel account deletion?", isPresented: $isShowingDeletionCancelConfirmation) {
            Button("Keep Request", role: .cancel) {}
            Button("Cancel Deletion") {
                cancelAccountDeletion()
            }
        } message: {
            Text("This keeps your ThreadShare account active and removes the pending deletion request.")
        }
        .alert(item: $activeAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(isPresented: $isShowingImmediateDeletionConfirmation) {
            ImmediateDeletionConfirmationView(
                confirmationStatement: Self.immediateDeletionConfirmationCopy,
                onConfirm: requestImmediateAccountDeletion
            )
        }
    }

    private var accountSection: some View {
        Section {
            if let user = currentUser {
                infoRow(title: "Signed In As", value: "@\(user.username)")
                infoRow(title: "Name", value: user.displayName)
            }

            if let email = sessionStore.session?.email {
                infoRow(title: "Email", value: email)
            } else {
                infoRow(title: "Session", value: "Demo mode active")
            }

        } header: {
            sectionHeader("Account", systemImage: "person.crop.circle")
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker("Appearance Mode", selection: appearanceSelection) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityHint("Choose system, light, or dark appearance for the app.")

            Text("Choose how ThreadShare should follow your device or override it here.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(AppTheme.surface)
        } header: {
            sectionHeader("Appearance", systemImage: "paintbrush")
        }
    }

#if DEBUG
    private var developerActivitySection: some View {
        Section {
            infoRow(
                title: "Last Login",
                value: formattedActivityTimestamp(currentUser?.lastLoginAt)
            )
            infoRow(
                title: "Last Active",
                value: formattedActivityTimestamp(currentUser?.lastActiveAt)
            )
            infoRow(
                title: "Inactive For",
                value: inactiveDurationText
            )

            Text("Developer note: this screen reads from `profiles.last_login_at` and `profiles.last_active_at`. Use Supabase SQL for full-user audits and future inactivity policies.")
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(AppTheme.surface)
        } header: {
            sectionHeader("Developer Activity", systemImage: "wrench.and.screwdriver")
        }
    }
#endif

    private var preferencesSection: some View {
        Section {
            infoRow(
                title: "Style Interests",
                value: currentUser?.styleInterestDisplayNames.isEmpty == false
                    ? currentUser!.styleInterestDisplayNames.joined(separator: ", ")
                    : "Not set yet"
            )
            infoRow(
                title: "Favorite Brands",
                value: currentUser?.favoriteBrands.isEmpty == false
                    ? currentUser!.favoriteBrands.joined(separator: ", ")
                    : "Not set yet"
            )
            infoRow(
                title: "Color Palettes",
                value: currentUser?.colorPalettePreferenceDisplayNames.isEmpty == false
                    ? currentUser!.colorPalettePreferenceDisplayNames.joined(separator: ", ")
                    : "Not set yet"
            )

            if let currentUser {
                NavigationLink {
                    EditProfileSheetView(user: currentUser)
                        .environmentObject(appState)
                } label: {
                    Label("Edit Preferences", systemImage: "slider.horizontal.3")
                }
                .foregroundStyle(AppTheme.ink)
                .accessibilityHint("Opens profile editing for style interests, brands, and color palettes.")
            }
        } header: {
            sectionHeader("Preferences", systemImage: "sparkles")
        }
    }

    private var socialSection: some View {
        Section {
            ShareLink(item: inviteMessage) {
                Label("Invite Friends", systemImage: "person.badge.plus")
            }
            .foregroundStyle(AppTheme.ink)
            .accessibilityHint("Opens the system share sheet with a prefilled invite message.")

            Text("Share an invite through Messages, Notes, or any app in your share sheet.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(AppTheme.surface)
        } header: {
            sectionHeader("Social", systemImage: "person.2")
        }
    }

    private var supportSection: some View {
        Section {
            NavigationLink {
                SupportCenterView(supportEmail: supportEmail)
            } label: {
                Label("Support & Reporting", systemImage: "questionmark.bubble")
            }
            .foregroundStyle(AppTheme.ink)
            .accessibilityHint("Open support contact details and reporting guidance.")

            Text("Use this for account help and reporting guidance.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(AppTheme.surface)
        } header: {
            sectionHeader("Support", systemImage: "questionmark.circle")
        }
    }

    private var legalSection: some View {
        Section {
            NavigationLink {
                PrivacyPolicyView(supportEmail: supportEmail)
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
            .foregroundStyle(AppTheme.ink)
            .accessibilityHint("Reviews how ThreadShare collects, uses, and shares information.")

            NavigationLink {
                TermsOfUseView(supportEmail: supportEmail)
            } label: {
                Label("Terms of Use", systemImage: "doc.text.fill")
            }
            .foregroundStyle(AppTheme.ink)
            .accessibilityHint("Reviews the ThreadShare terms for using the app.")

            Text("Review the legal terms that apply to your use of ThreadShare.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(AppTheme.surface)
        } header: {
            sectionHeader("Legal", systemImage: "doc.text.magnifyingglass")
        }
    }

    private var sessionSection: some View {
        Section {
            if sessionStore.session != nil {
                Button {
                    Task {
                        isLoggingOut = true
                        await sessionStore.signOut()
                        isLoggingOut = false
                    }
                } label: {
                    Label(isLoggingOut ? "Logging Out" : "Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .disabled(isLoggingOut)
                .foregroundStyle(AppTheme.ink)
                .accessibilityHint("Signs out of your current ThreadShare account.")
            } else {
                Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    .foregroundStyle(AppTheme.mutedInk)
                    .accessibilityLabel("Log Out unavailable")
                    .accessibilityHint("You are currently using demo mode, so there is no active account session.")
            }

            accountDeletionControls
        } header: {
            sectionHeader("Session & Account", systemImage: "exclamationmark.shield")
        }
    }

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(AppTheme.bodyFont(size: 13).weight(.semibold))
            .foregroundStyle(AppTheme.accent)
    }

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
            Text(value)
                .font(AppTheme.bodyFont(size: 15))
                .foregroundStyle(AppTheme.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
        .listRowBackground(AppTheme.surface)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }

    private func formattedActivityTimestamp(_ value: Date?) -> String {
        guard let value else { return "Not recorded yet" }
        return value.formatted(date: .abbreviated, time: .shortened)
    }

    private var inactiveDurationText: String {
        let reference = currentUser?.lastActiveAt ?? currentUser?.lastLoginAt
        guard let reference else { return "Not recorded yet" }
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: reference, to: Date())
        if let days = components.day, days > 0 {
            return "\(days) day\(days == 1 ? "" : "s")"
        }
        if let hours = components.hour, hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s")"
        }
        let minutes = max(0, components.minute ?? 0)
        return "\(minutes) minute\(minutes == 1 ? "" : "s")"
    }

    @ViewBuilder
    private var accountDeletionControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommended")
                .font(AppTheme.bodyFont(size: 13).weight(.semibold))
                .foregroundStyle(AppTheme.accent)
                .listRowBackground(AppTheme.surface)

            Text("Request deletion with a 14-day grace period so you can cancel anytime before the scheduled date.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(AppTheme.surface)
        }

        if let pendingRequest = appState.pendingAccountDeletionRequest {
            deletionStatusCard(pendingRequest)

            Button {
                isShowingDeletionCancelConfirmation = true
            } label: {
                Label("Cancel Account Deletion", systemImage: "xmark.circle")
            }
            .foregroundStyle(AppTheme.ink)
            .accessibilityHint("Keeps your account active and removes the pending deletion request.")
        } else {
            Button {
                isShowingDeletionRequestConfirmation = true
            } label: {
                Label("Request 14-Day Deletion", systemImage: "clock.arrow.circlepath")
            }
            .foregroundStyle(.red)
            .disabled(currentUser == nil)
            .accessibilityHint("Starts a 14 day grace period before permanent account deletion, and you can cancel during that period.")
        }

        if let immediateNotice = appState.immediateAccountDeletionNotice {
            immediateDeletionNoticeCard(immediateNotice)
        }

        VStack(alignment: .leading, spacing: 8) {
            Text("Advanced")
                .font(AppTheme.bodyFont(size: 13).weight(.semibold))
                .foregroundStyle(AppTheme.mutedInk)
                .listRowBackground(AppTheme.surface)

            Text("Immediate permanent deletion is intended for users who do not want the grace period. This path cannot be completed from the client and requires trusted backend support.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
                .listRowBackground(AppTheme.surface)

            Button(role: .destructive) {
                isShowingImmediateDeletionConfirmation = true
            } label: {
                Label("Immediate Permanent Deletion", systemImage: "exclamationmark.triangle.fill")
            }
            .foregroundStyle(.red)
            .disabled(currentUser == nil)
            .accessibilityHint("Opens an advanced confirmation flow for immediate permanent deletion.")
        }
    }

    private func deletionStatusCard(_ request: AccountDeletionRequest) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Deletion request pending", systemImage: "clock.badge.exclamationmark")
                .font(AppTheme.bodyFont(size: 15).weight(.semibold))
                .foregroundStyle(AppTheme.warmAccentHighlight)

            Text("Scheduled for \(request.scheduledDeletionDate.formatted(date: .abbreviated, time: .shortened)).")
                .font(AppTheme.bodyFont(size: 14))
                .foregroundStyle(AppTheme.ink)

            Text("You can cancel this request anytime before the scheduled deletion date.")
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .listRowBackground(AppTheme.warmAccentFill)
        .accessibilityElement(children: .combine)
    }

    private func immediateDeletionNoticeCard(_ notice: ImmediateAccountDeletionNotice) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Immediate deletion not completed", systemImage: "bolt.shield")
                .font(AppTheme.bodyFont(size: 15).weight(.semibold))
                .foregroundStyle(AppTheme.warmAccentHighlight)

            Text("Recorded on \(notice.requestedAt.formatted(date: .abbreviated, time: .shortened)).")
                .font(AppTheme.bodyFont(size: 14))
                .foregroundStyle(AppTheme.ink)

            Text(notice.backendRequirementMessage)
                .font(AppTheme.bodyFont(size: 13))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 4)
        .listRowBackground(AppTheme.warmAccentFill)
        .accessibilityElement(children: .combine)
    }

    private func requestAccountDeletion() {
        Task {
            guard await appState.requestAccountDeletion() != nil else { return }
            activeAlert = .deletionRequested
        }
    }

    private func cancelAccountDeletion() {
        Task {
            guard await appState.cancelAccountDeletion() else { return }
            activeAlert = .deletionCanceled
        }
    }

    private func requestImmediateAccountDeletion() {
        Task {
            guard await appState.requestImmediateAccountDeletion(
                confirmationStatement: Self.immediateDeletionConfirmationCopy
            ) != nil else { return }
            activeAlert = .immediateDeletionRecorded
        }
    }
}

private struct ImmediateDeletionConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasAcknowledgedPermanentDeletion = false

    let confirmationStatement: String
    let onConfirm: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Immediate Permanent Deletion") {
                    Text("This advanced option skips the 14-day grace period. ThreadShare still requires trusted backend support before an immediate permanent deletion can actually be carried out.")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.ink)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Your account will stay active until that backend deletion function exists and is triggered securely.")
                        .font(AppTheme.bodyFont(size: 13))
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Section("Required Confirmation") {
                    Toggle(isOn: $hasAcknowledgedPermanentDeletion) {
                        Text(confirmationStatement)
                            .font(AppTheme.bodyFont(size: 14))
                            .foregroundStyle(AppTheme.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .toggleStyle(.switch)
                }

                Section {
                    Button(role: .destructive) {
                        onConfirm()
                        dismiss()
                    } label: {
                        Text("Record Immediate Deletion Request")
                    }
                    .disabled(!hasAcknowledgedPermanentDeletion)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background.ignoresSafeArea())
            .listStyle(.insetGrouped)
            .navigationTitle("Immediate Deletion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct SupportCenterView: View {
    let supportEmail: String
    @State private var isShowingCopiedAlert = false

    var body: some View {
        List {
            Section("Contact") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Support Email")
                        .font(AppTheme.bodyFont(size: 13))
                        .foregroundStyle(AppTheme.mutedInk)
                    Text(supportEmail)
                        .font(AppTheme.bodyFont(size: 15))
                        .foregroundStyle(AppTheme.ink)
                }
                .padding(.vertical, 2)
                .listRowBackground(AppTheme.surface)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Support Email: \(supportEmail)")

                Button {
                    #if os(iOS)
                    UIPasteboard.general.string = supportEmail
                    #endif
                    isShowingCopiedAlert = true
                } label: {
                    Label("Copy Support Email", systemImage: "doc.on.doc")
                }
                .foregroundStyle(AppTheme.ink)
                .accessibilityHint("Copies the support email address to your clipboard.")
            }

            Section("Reporting") {
                Text("To report inappropriate content, open the item and use the report action from item details.")
                    .font(AppTheme.bodyFont(size: 14))
                    .foregroundStyle(AppTheme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .listRowBackground(AppTheme.surface)

                Text("Reports are queued for manual review in this release.")
                    .font(AppTheme.bodyFont(size: 13))
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
                    .listRowBackground(AppTheme.surface)
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Copied", isPresented: $isShowingCopiedAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Support email copied to your clipboard.")
        }
    }
}

private struct PrivacyPolicyView: View {
    let supportEmail: String

    var body: some View {
        List {
            Section {
                legalParagraph("ThreadShare collects and uses information you provide and information generated through your use of the app so the service can operate, personalize your experience, and provide support.")
                legalParagraph("This may include account and profile data, user-generated content such as photos, item details, comments, messages, reports, and activity or preference data related to how you use the app.")
                legalParagraph("We may use information to operate and improve the app, personalize content, provide customer support, help keep the service safe, understand usage and analytics, and send service or marketing communications when permitted by law and your choices.")
                legalParagraph("We may share information with service providers and other third parties as allowed to support hosting, storage, analytics, moderation, communication, and app operation. We do not sell your personal data in a way that conflicts with applicable law.")
            } header: {
                Text("Privacy Policy")
            }

            Section("Your Choices") {
                legalParagraph("You can update certain profile and preference details in the app. You can also request account deletion from Settings, which starts a 14-day grace period before permanent deletion is processed on the server.")
                legalParagraph("If you contact us, we may use the information you share to respond to your request and keep a record of the conversation as needed for support or safety.")
            }

            Section("Camera and Photos") {
                legalParagraph("When you choose to use the camera or photo library, ThreadShare uses that access to let you create and edit item photos and related content inside the app. Camera and photo data are used for app functionality and are not used for advertising or third-party data mining through Apple Camera or Photo APIs.")
            }

            Section("Contact") {
                legalParagraph("Questions about this policy can be sent to \(supportEmail).")
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func legalParagraph(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.bodyFont(size: 14))
            .foregroundStyle(AppTheme.ink)
            .fixedSize(horizontal: false, vertical: true)
            .listRowBackground(AppTheme.surface)
    }
}

private struct TermsOfUseView: View {
    let supportEmail: String

    var body: some View {
        List {
            Section {
                legalParagraph("By using ThreadShare, you agree to use the app in a lawful, respectful manner and to follow these terms and any applicable app rules or policies.")
                legalParagraph("You are responsible for the content you post or share, including photos, item details, comments, messages, reports, and any other user-generated content. Do not upload content that is unlawful, abusive, deceptive, infringing, or otherwise harmful.")
                legalParagraph("Borrowing and lending decisions are ultimately between users. ThreadShare may help you discover, request, coordinate, and track items, but it does not guarantee condition, fit, availability, ownership, or fulfillment of any transaction or exchange between users.")
            } header: {
                Text("Terms of Use")
            }

            Section("Moderation and Safety") {
                legalParagraph("ThreadShare may review, moderate, restrict, or remove content and accounts that violate these terms, applicable law, or safety expectations. You may use reporting tools to flag content or behavior for review.")
            }

            Section("Account and Deletion") {
                legalParagraph("You are responsible for maintaining the security of your account. You may request account deletion from Settings. Deletion requests enter a 14-day grace period before permanent deletion is completed on the server.")
            }

            Section("Contact") {
                legalParagraph("Questions about these terms can be sent to \(supportEmail).")
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background.ignoresSafeArea())
        .listStyle(.insetGrouped)
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func legalParagraph(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.bodyFont(size: 14))
            .foregroundStyle(AppTheme.ink)
            .fixedSize(horizontal: false, vertical: true)
            .listRowBackground(AppTheme.surface)
    }
}
