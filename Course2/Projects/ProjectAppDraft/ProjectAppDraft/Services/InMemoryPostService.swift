//
//  InMemoryPostService.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/8/26.
//
import Foundation

class InMemoryPostService: PostService {
    private var posts: [Post]
    private var commentsByPost: [UUID: [Comment]]
    private var likesByPost: [UUID: Set<UUID>] // postID -> set of userIDs who liked

    init(
        seedPosts: [Post] = [],
        seedComments: [UUID: [Comment]] = [:],
        seedLikes: [UUID: Set<UUID>] = [:]
    ) {
        self.posts = seedPosts.sorted(by: { $0.date > $1.date })
        self.commentsByPost = seedComments
        self.likesByPost = seedLikes
    }

    // adding posts
    func fetchTimeline() async throws -> [Post] {
        posts
    }
    
    // fetchPosts unused now, but will be ready for API
    func fetchPosts(for authorID: UUID) async throws -> [Post] {
        posts.filter { $0.authorID == authorID }
    }
    
    func createPost(_ post: Post) async throws -> Post {
        posts.insert(post, at: 0)
        return post
    }

    // adding comments
    func fetchComments(for postID: UUID) async throws -> [Comment] {
        commentsByPost[postID] ?? []
    }
    
    func addComment(_ comment: Comment) async throws -> Comment {
        commentsByPost[comment.postID, default: []].append(comment)
        return comment
    }
    
    func commentCount(for postID: UUID) async throws -> Int {
        commentsByPost[postID]?.count ?? 0
    }

    // managing likes
    func likeCount(for postID: UUID) async throws -> Int {
        likesByPost[postID]?.count ?? 0
    }
    
    func isLiked(postID: UUID, by userID: UUID) async throws -> Bool {
        likesByPost[postID]?.contains(userID) ?? false
    }
    
    func toggleLike(postID: UUID, by userID: UUID) async throws -> (isLiked: Bool, likeCount: Int) {
        var set = likesByPost[postID] ?? []
        if set.contains(userID) {
            set.remove(userID)
        } else {
            set.insert(userID)
        }
        likesByPost[postID] = set
        return (set.contains(userID), set.count)
    }
}
