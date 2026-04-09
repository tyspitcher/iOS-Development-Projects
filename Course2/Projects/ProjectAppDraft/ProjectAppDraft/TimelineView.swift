//
//  TimelineView.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 3/31/26.
//

import SwiftUI

struct TimelineView: View {
    @State var viewModel: TimelineViewModel
    let currentUserID: UUID
    var body: some View {
        NavigationStack {
            List {
                Section("Your Recent Posts") {
                    ForEach(viewModel.posts.filter { $0.authorID == currentUserID }) { post in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(post.content)
                            Text(post.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                Section("Recent User Posts") {
                    ForEach(viewModel.posts.filter { $0.authorID != currentUserID }) { post in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(post.content)
                            Text(post.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Timeline")
            .task { await viewModel.loadTimeline() }
        }
    }
}

#Preview {
    let service = InMemoryPostService(seedPosts: userPosts)
    return TimelineView(viewModel: TimelineViewModel(postService: service), currentUserID: tyson.id)
}
/* I'd like to implement a like button to the left of the post. In order to keep with my space theme I'd like the button to use the system image 'star' if the comment has not been liked yet and then 'star.fill' if the comment has been liked. I'd also like to create another line below the date that will have the comment count which is also a tappable feature that will bring up a modal sheet in which the user can view any comments (if there are any) and at the bottom of the sheet the user can add their own comments. Let's create a new CommentView and CommentViewModel first so that there is already a place to navigate to before we implement the other changes.*/

