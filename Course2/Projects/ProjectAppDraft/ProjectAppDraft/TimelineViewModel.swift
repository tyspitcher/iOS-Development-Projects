//
//  TimelineViewModel.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/1/26.
//

import Foundation
import SwiftUI
import Observation

@Observable
class TimelineViewModel {
    var posts: [Post] = []
    var isLoading = false
    var errorMessage: String?

    private let postService: PostService

    init(postService: PostService) {
        self.postService = postService
    }

    @MainActor
    func loadTimeline() async {
        if isLoading { return }
        isLoading = true
        defer { isLoading = false }
        do {
            posts = try await postService.fetchTimeline()
        } catch {
            errorMessage = "Failed to load timeline."
        }
    }

    @MainActor
    func add(_ post: Post) {
        posts.insert(post, at: 0)
    }
}
