//
//  CommentView.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/12/26.
//
import SwiftUI
import Foundation

struct CommentView: View {
    @State var viewModel: CommentViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Comments"){
                ForEach(viewModel.comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(authorName(for: comment.authorID))
                            .font(.headline)
                        Text(comment.content)
                        Text(comment.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            Section {
                TextField("Add a comment...", text: $viewModel.newCommentText)
                Button("Post Comment") {
                    Task {
                        let success = await viewModel.addComment()
                        if success {
                            dismiss()
                        }
                    }
                }
                .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Comments")
        .task { await viewModel.loadComments() }
    }
    private func authorName(for id: UUID) -> String {
        if id == tyson.id { return tyson.userName }
        if id == steph.id { return steph.userName }
        return "User"
    }
}


#Preview {
    let service = InMemoryPostService(seedPosts: [])
    let postID = UUID()
    let currentUserID = UUID()
    return CommentView(
        viewModel: CommentViewModel(
            postID: postID,
            currentUserID: currentUserID,
            postService: service
        )
    )
}
