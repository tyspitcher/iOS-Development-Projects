//
//  EditProfileSheetView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI

struct EditProfileSheetView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var sessionStore: SupabaseSessionStore
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: EditProfileViewModel
    @State private var selectedAvatarData: Data?
    @State private var isSaving = false
    @State private var activeAlertMessage: String?

    init(user: UserProfile) {
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    profilePhotoSection

                    profileField(label: "Name") {
                        TextField("Name", text: $viewModel.displayName)
                            .textContentType(.name)
                            .accessibilityLabel("Name")
                    }

                    profileField(label: "Username") {
                        TextField("Username", text: $viewModel.username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .accessibilityLabel("Username")
                    }

                    profileField(label: "City and State") {
                        TextField("City", text: $viewModel.city)
                            .textContentType(.addressCity)
                            .accessibilityLabel("City and State")
                    }

                    profileField(label: "Bio") {
                        TextField("Bio", text: $viewModel.bio, axis: .vertical)
                            .lineLimit(3...6)
                            .accessibilityLabel("Bio")
                            .accessibilityHint("Optional profile description.")
                    }
                }

                Section("Visibility") {
                    Picker("Profile visibility", selection: $viewModel.visibility) {
                        ForEach(ProfileVisibility.allCases) { visibility in
                            Text(visibility.displayName).tag(visibility)
                        }
                    }
                    .accessibilityHint("Controls who can see your profile.")

                    Toggle(isOn: $viewModel.isClosetPublic) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Public closet")
                                .font(AppTheme.bodyFont(size: 14))
                                .foregroundStyle(AppTheme.ink)

                            Text("Turn this off to keep closet visibility private.")
                                .font(AppTheme.bodyFont(size: 12))
                                .foregroundStyle(AppTheme.mutedInk)
                        }
                    }
                    .toggleStyle(.switch)
                    .accessibilityHint("Turn off to keep your closet private.")

                    Toggle(isOn: $viewModel.requiresFollowerApproval) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Approve followers")
                                .font(AppTheme.bodyFont(size: 14))
                                .foregroundStyle(AppTheme.ink)

                            Text("When on, new followers must send a request before they can follow you.")
                                .font(AppTheme.bodyFont(size: 12))
                                .foregroundStyle(AppTheme.mutedInk)
                        }
                    }
                    .toggleStyle(.switch)
                    .accessibilityHint("Require approval before someone can follow you.")
                }

                Section("Preferences") {
                    FashionPreferenceSelectionView(
                        selection: $viewModel.preferenceSelection,
                        customBrandEntry: $viewModel.customBrandEntry
                    )
                    .padding(.vertical, 4)
                }
            }
            .font(AppTheme.bodyFont(size: 16))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: viewModel.visibility) { _, _ in
                viewModel.syncClosetAccessFromVisibility()
            }
            .onChange(of: viewModel.isClosetPublic) { _, _ in
                viewModel.syncVisibilityFromClosetAccess()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(AppTheme.bodyFont(size: 16))
                        .accessibilityHint("Discard profile edits and close this screen.")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .font(AppTheme.bodyFont(size: 16))
                    .disabled(!viewModel.canSave || isSaving)
                    .accessibilityHint("Save profile updates and close this screen.")
                }
            }
            .alert("Profile Photo", isPresented: Binding(
                get: { activeAlertMessage != nil },
                set: { if $0 == false { activeAlertMessage = nil } }
            )) {
                Button("OK", role: .cancel) {
                    activeAlertMessage = nil
                }
            } message: {
                Text(activeAlertMessage ?? "Unable to update the profile photo.")
            }
        }
    }

    private var profilePhotoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photo")
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.accent)
                .textCase(.uppercase)

            HStack(alignment: .center, spacing: 14) {
                Group {
                    if let selectedAvatarData {
                        DataBackedImageView(data: selectedAvatarData, contentMode: .fill)
                    } else {
                        UserAvatarView(imageName: viewModel.avatarImageName, size: 84)
                    }
                }
                .frame(width: 84, height: 84)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.border, lineWidth: 1))

                VStack(alignment: .leading, spacing: 6) {
                    Text("Update your profile photo from your library or camera.")
                        .font(AppTheme.bodyFont(size: 13))
                        .foregroundStyle(AppTheme.mutedInk)
                        .fixedSize(horizontal: false, vertical: true)

                    ProfilePhotoSourcePicker(
                        previewImageData: selectedAvatarData,
                        onLibraryImageData: handleLibraryImageData,
                        onCameraImageData: handleCameraImageData,
                        onError: handleAvatarError
                    )
                }
            }
        }
        .padding(.vertical, 3)
    }

    private func profileField<Content: View>(
        label: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.accent)
                .textCase(.uppercase)

            content()
                .font(AppTheme.bodyFont(size: 16))
                .foregroundStyle(AppTheme.ink)
        }
        .padding(.vertical, 3)
    }

    private func saveProfile() {
        Task {
            isSaving = true
            defer { isSaving = false }

            do {
                let previousAvatarPath = viewModel.avatarImageName
                let avatarPayloadData = selectedAvatarData
                if let avatarPayloadData {
                    if sessionStore.session != nil {
                        let storageService = SupabaseStorageService(sessionProvider: sessionStore)
                        let avatarPath = try await storageService.uploadAvatarImage(
                            avatarPayloadData,
                            contentType: "image/jpeg",
                            userID: viewModel.userID
                        )
                        if previousAvatarPath != avatarPath, previousAvatarPath.contains("/") {
                            try? await storageService.deleteAvatarImage(at: previousAvatarPath)
                        }
                        viewModel.avatarImageName = avatarPath
                    } else {
                        let avatarFileName = try ProfileAvatarStore.saveLocalAvatarImageData(
                            avatarPayloadData,
                            userID: viewModel.userID
                        )
                        viewModel.avatarImageName = avatarFileName
                    }
                }

                appState.updateCurrentUser(viewModel.makeUpdatedUser())
                dismiss()
            } catch {
                activeAlertMessage = "We couldn't save the selected profile photo right now. \(error.localizedDescription)"
            }
        }
    }

    private func handleLibraryImageData(_ data: Data) {
        selectedAvatarData = data
    }

    private func handleCameraImageData(_ data: Data) {
        selectedAvatarData = data
    }

    private func handleAvatarError(_ message: String) {
        activeAlertMessage = message
    }
}
