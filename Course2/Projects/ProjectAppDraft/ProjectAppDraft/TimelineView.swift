//
//  TimelineView.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 3/31/26.
//
import Foundation
import SwiftUI

struct TimelineView: View {
    @State var viewModel: TimelineViewModel
    @State private var selectedPostForComments: Post?
    let currentUserID: UUID

    var body: some View {
        List {
            Section("My Recent Posts") {
                ForEach(viewModel.posts.filter { $0.authorID == currentUserID }) { post in
                    TimelinePostRow(
                        post: post,
                        authorName: viewModel.authorName(for: post.authorID),
                        isLiked: viewModel.isLikedByCurrentUser[post.id] ?? false,
                        likeCount: viewModel.likeCounts[post.id] ?? 0,
                        commentCount: viewModel.commentCounts[post.id] ?? 0,
                        onLikeTap: {
                            Task { await viewModel.toggleLike(for: post.id) }
                        },
                        onCommentTap: {
                            selectedPostForComments = post
                        }
                    )
                }
            }

            Section("Other HiTL User Posts") {
                ForEach(viewModel.posts.filter { $0.authorID != currentUserID }) { post in
                    TimelinePostRow(
                        post: post,
                        authorName: viewModel.authorName(for: post.authorID),
                        isLiked: viewModel.isLikedByCurrentUser[post.id] ?? false,
                        likeCount: viewModel.likeCounts[post.id] ?? 0,
                        commentCount: viewModel.commentCounts[post.id] ?? 0,
                        onLikeTap: {
                            Task { await viewModel.toggleLike(for: post.id) }
                        },
                        onCommentTap: {
                            selectedPostForComments = post
                        }
                    )
                }
            }
        }
        .task {
            await viewModel.loadTimeline()
        }
        .sheet(item: $selectedPostForComments, onDismiss: {
            Task { await viewModel.loadTimeline() }
        }) { post in
            NavigationStack {
                CommentView(
                    viewModel: CommentViewModel(
                        postID: post.id,
                        currentUserID: currentUserID,
                        postService: viewModel.postService
                    )
                )
            }
        }
    }
}

#Preview {
    let service = InMemoryPostService(
        seedPosts: userPosts,
        seedComments: seedCommentsByPost
    )
    TimelineView(
        viewModel: TimelineViewModel(postService: service, currentUserID: tyson.id),
        currentUserID: tyson.id
    )
}
