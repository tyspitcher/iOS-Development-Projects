//
//  UserProfileViewModel.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 3/31/26.
//

import Foundation
import SwiftUI
import Observation





// storage array for user posts, initializing with dummy data to
// create and test my UI
var userPosts: [Post] = [
    // Most recent post by Tyson
    Post(
        id: UUID(),
        authorID: tyson.id,
        date: Date(),
        content: "Just shipped a new feature in SwiftUI! Loving Observation and the new materials. 🚀"
    ),
    // Earlier post by Steph
    Post(
        id: UUID(),
        authorID: steph.id,
        date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
        content: "Trying out this app Tyson is building. Not bad! 😉"
    ),
    // Another Tyson post from yesterday
    Post(
        id: UUID(),
        authorID: tyson.id,
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
        content: "Experimenting with edge-to-edge banner images and avatar overlays."
    ),
    // Another Steph post from two days ago
    Post(
        id: UUID(),
        authorID: steph.id,
        date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
        content: "PC life chose me. But I do like the look of SwiftUI forms!"
    )
]



@Observable
class UserProfileViewModel {
    // UI state
    var isPresentingNewPost = false
    
    // screen specific presentation state
    var displayedUser: UserProfile
    var posts: [Post] = []
    var commentsByPost: [UUID: [Comment]] = [:]
    var recentPost: Post? {
        posts.first(where: { $0.authorID == displayedUser.id })
    }
    
    init(user: UserProfile) {
        self.displayedUser = user
    }
    
    var backgroundImage: String? { displayedUser.backgroundImage ?? String("defaultBackground") }
    var profileImage: String? { displayedUser.profileImage ?? String("user") }
    var firstName: String { displayedUser.firstName }
    var lastName: String { displayedUser.lastName }
    var userName: String { displayedUser.userName }
    var bio: String { displayedUser.bio }
    
    func presentNewPost() {
        isPresentingNewPost = true
    }

    func dismissNewPost() {
        isPresentingNewPost = false
    }
    
    func addPost(_ post: Post) {
        posts.insert(post, at: 0)
    }
    
    func comments(for post: Post) -> [Comment] {
        commentsByPost[post.id] ?? []
    }
}


// dummy info for users
let tyson = UserProfile(id: UUID(), firstName: "Tyson", lastName: "Pitcher", userName: "tyson.pitcher", bio: "I'm a software engineer", techInterests: "Swift, SwiftUI, and more!", profileImage: nil, backgroundImage: nil)

let steph = UserProfile(id: UUID(), firstName: "Steph", lastName: "Pitcher", userName: "kotta16", bio: "I'm not big on coding, but I'm big on my husband, and he likes to code.", techInterests: "I have a PC laptop.", profileImage: nil, backgroundImage: nil)
