//
//  EditProfileViewModel.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/1/26.
//
import Foundation
import Observation

// protocol that this VM can use, change later to implement real API calls
protocol UserProfileService {
    func updateProfile(_ profile: User) async throws -> User
}

// creating editable struct to avoid mutating the domain model until user
// taps 'save' button
struct EditableUserProfile: Equatable {
    var firstName: String
    var lastName: String
    var userName: String
    var bio: String
    var techInterests: String
    var profileImage: String?
    var backgroundImage: String?
    
    init(from profile: User) {
        self.firstName = profile.firstName
        self.lastName = profile.lastName
        self.userName = profile.userName
        self.bio = profile.bio
        self.techInterests = profile.techInterests
        if let profileImage = profile.profileImage {
            self.profileImage = profileImage
        } else {
            self.profileImage = nil
        }
        if let backgroundImage = profile.backgroundImage {
            self.backgroundImage = backgroundImage
        } else {
            self.backgroundImage = nil
        }
    }
    
    func applying(to profile: User) -> User {
        var updated = profile
        updated.firstName = firstName
        updated.lastName = lastName
        updated.userName = userName
        updated.bio = bio
        updated.techInterests = techInterests
        if let profileImage = profileImage {
            updated.profileImage = profileImage
        }
        if let backgroundImage = backgroundImage {
            updated.backgroundImage = backgroundImage
        }
        return updated
    }
    
}

// temporary dummy data for previews and testing
struct MockUserProfileService: UserProfileService {
    func updateProfile(_ profile: User) async throws -> User {
        try await Task.sleep(nanoseconds: 400_000_000) // simulate latency
        return profile // echo back
    }
}
@Observable
class EditProfileViewModel {
    // form inputs
    var form: EditableUserProfile
    
    // UI state
    var isSaving = false
    var errorMessage: String?
    
    // dependencies
    private let original: User
    private let service: UserProfileService
    private let onSave: (User) -> Void
    
    init(
        user: User,
        service: UserProfileService = MockUserProfileService(),
        onSave: @escaping (User) -> Void
    ) {
        self.original = user
        self.form = EditableUserProfile(from: user)
        self.service = service
        self.onSave = onSave
    }
    
    // save action
    @MainActor
    func save() async {
        if isSaving { return }
        isSaving = true

        let updated = form.applying(to: original)
        do {
            let saved = try await service.updateProfile(updated)
            onSave(saved)
        } catch {
            errorMessage = "Failed to save your profile. Please try again."
        }
    }
}
