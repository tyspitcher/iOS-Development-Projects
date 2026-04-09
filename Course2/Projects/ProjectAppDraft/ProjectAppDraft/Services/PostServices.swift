//
//  PostServices.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/8/26.
//

import Foundation

protocol PostService {
    // posts
    func fetchTimeline() async throws -> [Post]
    func fetchPosts(for authorID: UUID) async throws -> [Post]
    func createPost(_ post: Post) async throws -> Post

    // comments
    func fetchComments(for postID: UUID) async throws -> [Comment]
    func addComment(_ comment: Comment) async throws -> Comment

    // counts and likes
    func commentCount(for postID: UUID) async throws -> Int
    func likeCount(for postID: UUID) async throws -> Int
    func isLiked(postID: UUID, by userID: UUID) async throws -> Bool
    func toggleLike(postID: UUID, by userID: UUID) async throws -> (isLiked: Bool, likeCount: Int)
}
