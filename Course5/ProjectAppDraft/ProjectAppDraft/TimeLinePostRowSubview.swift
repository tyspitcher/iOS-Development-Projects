//
//  TimeLinePostRowSubview.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 4/13/26.
//
import SwiftUI
import Foundation

struct TimelinePostRow: View {
    let post: Post
    let authorName: String?
    let isLiked: Bool
    let likeCount: Int
    let commentCount: Int
    let onLikeTap: () -> Void
    let onCommentTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 4) {
                Button(action: onLikeTap) {
                    Image(systemName: isLiked ? "star.fill" : "star")
                        .foregroundStyle(isLiked ? .yellow : .secondary)
                }
                .buttonStyle(.plain)

                Text("\(likeCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 28)

            VStack(alignment: .leading, spacing: 8) {
                Text(post.content)
                if let authorName, !authorName.isEmpty {
                    Text("@\(authorName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(post.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(action: onCommentTap) {
                    Label("\(commentCount)", systemImage: "text.bubble")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}
