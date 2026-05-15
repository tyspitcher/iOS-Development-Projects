//
//  EditProfileSheetView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI

struct EditProfileSheetView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var draftUser: UserProfile
    @State private var styleInterestsText: String
    @State private var favoriteBrandsText: String
    @State private var isClosetPublic: Bool

    init(user: UserProfile) {
        _draftUser = State(initialValue: user)
        _styleInterestsText = State(initialValue: user.styleInterests.joined(separator: ", "))
        _favoriteBrandsText = State(initialValue: user.favoriteBrands.joined(separator: ", "))
        _isClosetPublic = State(initialValue: user.visibility == .publicProfile)
    }

    private var canSave: Bool {
        !draftUser.displayName.trimmed.isEmpty &&
        !draftUser.username.trimmed.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    profileField(label: "Name") {
                        TextField("Name", text: $draftUser.displayName)
                    }

                    profileField(label: "Username") {
                        TextField("Username", text: $draftUser.username)
                            .textInputAutocapitalization(.never)
                    }

                    profileField(label: "City and State") {
                        TextField("City", text: $draftUser.city)
                    }

                    profileField(label: "Bio") {
                        TextField("Bio", text: $draftUser.bio, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }

                Section("Visibility") {
                    Picker("Profile visibility", selection: $draftUser.visibility) {
                        ForEach(ProfileVisibility.allCases) { visibility in
                            Text(visibility.displayName).tag(visibility)
                        }
                    }

                    Toggle(isOn: $isClosetPublic) {
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
                }

                Section("Style") {
                    profileField(label: "Style interests") {
                        TextField("Style interests", text: $styleInterestsText, axis: .vertical)
                            .lineLimit(2...4)
                    }

                    profileField(label: "Favorite brands") {
                        TextField("Favorite brands", text: $favoriteBrandsText, axis: .vertical)
                            .lineLimit(2...4)
                    }
                }
            }
            .font(AppTheme.bodyFont(size: 16))
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: draftUser.visibility) { _, visibility in
                isClosetPublic = visibility == .publicProfile
            }
            .onChange(of: isClosetPublic) { _, isPublic in
                draftUser.visibility = isPublic ? .publicProfile : .privateProfile
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(AppTheme.bodyFont(size: 16))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .font(AppTheme.bodyFont(size: 16))
                    .disabled(!canSave)
                }
            }
        }
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
        draftUser.displayName = draftUser.displayName.trimmed
        draftUser.username = draftUser.username.trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        draftUser.city = draftUser.city.trimmed
        draftUser.bio = draftUser.bio.trimmed
        draftUser.styleInterests = commaSeparatedValues(from: styleInterestsText)
        draftUser.favoriteBrands = commaSeparatedValues(from: favoriteBrandsText)

        appState.updateCurrentUser(draftUser)
        dismiss()
    }

    private func commaSeparatedValues(from text: String) -> [String] {
        text
            .split(separator: ",")
            .map { String($0).trimmed }
            .filter { !$0.isEmpty }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
