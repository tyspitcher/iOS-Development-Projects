//
//  ParentTabViewModel.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/12/26.
//
import Foundation
import Observation

@Observable
class ParentTabViewModel {
    var user: User
    var isPresentingNewPost = false
    let postService: PostService


    // child VMs
    var userProfileViewModel: UserProfileViewModel
    var timelineViewModel: TimelineViewModel
    var newPostViewModel: NewPostViewModel
    
    init(
        user: User,
        postService: PostService = InMemoryPostService(
            seedPosts: userPosts,
            seedComments: seedCommentsByPost
        )
    ) {
        self.user = user
        self.postService = postService
        
        
        self.userProfileViewModel = UserProfileViewModel(user: user)
        self.timelineViewModel = TimelineViewModel(
            postService: postService,
            currentUserID: user.id
        )
        self.newPostViewModel = NewPostViewModel(
            postService: postService,
            currentUserID: user.id
        )

    }

    func presentNewPost() { isPresentingNewPost = true }
    func dismissNewPost() { isPresentingNewPost = false }
}
