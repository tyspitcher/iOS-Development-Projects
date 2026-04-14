//
//  NewPostViewModel.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/1/26.
//
import Foundation
import Observation

@Observable
final class NewPostViewModel {
    // inputs
    var title: String = ""
    var body: String = ""
    
    // UI state
    var isSubmitting: Bool = false

    // used to catch errors with new posts
    var errorMessage: String?
    
    // dependencies
    let postService: PostService
    let currentUserID: UUID
    
    init(postService: PostService, currentUserID: UUID) {
        self.postService = postService
        self.currentUserID = currentUserID
    }
    
    // checks in place to make sure a blank post isn't created by accident
    var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }
    
    @MainActor
    func submitPost(onSuccess: @escaping () -> Void) async {
        guard canSubmit else { return }
        isSubmitting = true

        
        let newPost = Post(
            id: UUID(),
            authorID: currentUserID,
            date: Date(),
            content: body.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        do {
            _ = try await postService.createPost(newPost)
            title = ""
            body = ""
            onSuccess()
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isSubmitting = false
    }
}

