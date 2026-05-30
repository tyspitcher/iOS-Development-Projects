//
//  EditProfileViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/22/26.
//

import Foundation
import Combine

@MainActor
final class EditProfileViewModel: ObservableObject {
    @Published var displayName: String
    @Published var username: String
    @Published var city: String
    @Published var bio: String
    @Published var visibility: ProfileVisibility
    @Published var isClosetPublic: Bool
    @Published var avatarImageName: String
    @Published var preferenceSelection: FashionPreferenceSelection
    @Published var customBrandEntry = ""

    private let originalUser: UserProfile

    var userID: UserProfile.ID {
        originalUser.id
    }

    init(user: UserProfile) {
        originalUser = user
        displayName = user.displayName
        username = user.username
        city = user.city
        bio = user.bio
        visibility = user.visibility
        isClosetPublic = user.visibility == .publicProfile
        avatarImageName = user.avatarImageName
        preferenceSelection = user.fashionPreferenceSelection
    }

    var canSave: Bool {
        displayName.trimmed.isEmpty == false &&
        username.trimmed.isEmpty == false
    }

    func syncVisibilityFromClosetAccess() {
        visibility = isClosetPublic ? .publicProfile : .privateProfile
    }

    func syncClosetAccessFromVisibility() {
        isClosetPublic = visibility == .publicProfile
    }

    func makeUpdatedUser() -> UserProfile {
        var user = originalUser
        user.displayName = displayName.trimmed
        user.username = username.trimmed.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
        user.city = city.trimmed
        user.bio = bio.trimmed
        user.avatarImageName = avatarImageName
        user.visibility = visibility
        user.styleInterests = preferenceSelection.styleIDs
        user.favoriteBrands = preferenceSelection.favoriteBrands
        user.colorPalettePreferenceIDs = preferenceSelection.colorPaletteIDs
        return user
    }
}
