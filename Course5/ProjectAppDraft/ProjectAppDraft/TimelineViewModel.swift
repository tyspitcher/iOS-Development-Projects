//
//  TimelineViewModel.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/1/26.
//
import Foundation
import Observation

@Observable
class TimelineViewModel {
    var posts: [Post] = []
    var isLoading = false
    var errorMessage: String?
    let postService: PostService
    
    // creating dictionaries for like counts and comment counts using post
    // UUID for the key
    var likeCounts: [UUID: Int] = [:]
    var isLikedByCurrentUser: [UUID: Bool] = [:]
    var commentCounts: [UUID: Int] = [:]
    
    var currentUserID: UUID?
    
    init(postService: PostService, currentUserID: UUID? = nil) {
        self.postService = postService
        self.currentUserID = currentUserID
    }


    @MainActor
    func loadTimeline() async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }   // <- important
        
        do {
            let fetched = try await postService.fetchTimeline()
            posts = fetched
            // loading likes and comments for posts
            await withTaskGroup(of: Void.self) { group in
                for post in fetched {
                    group.addTask { [postService] in
                        async let likeCount = try? postService.likeCount(for: post.id)
                        async let commentCount = try? postService.commentCount(for: post.id)
                        let likes = await (likeCount ?? 0)
                        let comments = await (commentCount ?? 0)
                        await MainActor.run {
                            self.likeCounts[post.id] = likes
                            self.commentCounts[post.id] = comments
                        }
                    }
                    if let uid = currentUserID {
                        group.addTask { [postService] in
                            let liked = (try? await postService.isLiked(postID: post.id, by: uid)) ?? false
                            await MainActor.run {
                                self.isLikedByCurrentUser[post.id] = liked
                            }
                        }
                    }
                }
            }
        } catch {
        }
    }
    
    @MainActor
    func toggleLike(for postID: UUID) async {
        guard let userID = currentUserID else { return }
        do {
            let result = try await postService.toggleLike(postID: postID, by: userID)
            isLikedByCurrentUser[postID] = result.isLiked
            likeCounts[postID] = result.likeCount
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
    
    // mapping dummy users by ID for placeholder until API/user service exists
    private let usersByID: [UUID: User] = [
        tyson.id: tyson,
        steph.id: steph
    ]

    func authorName(for authorID: UUID) -> String {
        usersByID[authorID]?.userName ?? "Unknown User"
    }

}
