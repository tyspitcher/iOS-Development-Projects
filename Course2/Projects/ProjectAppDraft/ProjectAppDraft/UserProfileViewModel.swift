//
//  UserProfileViewModel.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 3/31/26.
//
import Foundation
import Observation

@Observable
class UserProfileViewModel {
    
    // screen specific presentation state
    var displayedUser: User
    var posts: [Post] = userPosts // dummy data, need to remove when hooked up to API
    var recentPost: Post? {
        posts.first(where: { $0.authorID == displayedUser.id })
    }
    
    init(user: User) {
        self.displayedUser = user
    }
}


