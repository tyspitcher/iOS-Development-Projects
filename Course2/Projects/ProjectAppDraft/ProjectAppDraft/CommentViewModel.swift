//
//  CommentViewModel.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/8/26.
//
import Observation
import Foundation

struct Comment: Identifiable, Codable, Equatable {
    let id: UUID
    let postID: UUID
    let authorID: UUID
    let date: Date
    let content: String
}
@Observable
class CommentViewModel {
    let postID: UUID
    let currentUserID: UUID
    private let postService: PostService
    
    var comments: [Comment] = []
    var newCommentText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    init(postID: UUID, currentUserID: UUID, postService: PostService) {
        self.postID = postID
        self.currentUserID = currentUserID
        self.postService = postService
    }
    
    @MainActor
    func loadComments() async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }

        do {
            comments = try await postService.fetchComments(for: postID)
        } catch {
            errorMessage = "Failed to load comments. Please try again."
        }
    }

    @MainActor
    func addComment() async -> Bool {
        // checks in place to make sure a blank comment isn't saved
        let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        let comment = Comment(
            id: UUID(),
            postID: postID,
            authorID: currentUserID,
            date: Date(),
            content: trimmed
        )
        do {
            let created = try await postService.addComment(comment)
            comments.append(created)
            newCommentText = ""
            return true
        } catch {
            errorMessage = "Failed to add comment. Please try again."
            return false
        }
    }
}
