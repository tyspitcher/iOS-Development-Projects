//
//  DMChatView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

struct DMChatView: View {
    @Environment(\.dismiss) private var dismiss

    let owner: UserProfile
    let item: ThreadItem?

    @State private var draftMessage = "Hey! Is this still available to borrow?"
    @State private var messages: [LocalChatMessage] = [
        LocalChatMessage(text: "Hey! I saw your closet and loved your style.", isCurrentUser: true),
        LocalChatMessage(text: "Thank you! Happy to share pieces when they are available.", isCurrentUser: false),
        LocalChatMessage(text: "Just message me about what you are thinking for dates.", isCurrentUser: false)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {
                            if let item {
                                itemPreview(item)
                            }

                            ForEach(messages) { message in
                                messageBubble(message)
                            }
                        }
                        .padding(AppTheme.pagePadding)
                    }

                    composer
                }
            }
            .navigationTitle("Message")
            .toolbar {
                ToolbarItem(placement: trailingToolbarPlacement) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            UserAvatarView(imageName: owner.avatarImageName, size: 52)

            VStack(alignment: .leading, spacing: 3) {
                Text(owner.displayName)
                    .font(AppTheme.titleFont(size: 20))
                    .foregroundStyle(AppTheme.ink)

                Text("@\(owner.username)")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            Spacer()

            RelationshipBadge(relationship: owner.relationship)
        }
        .padding(AppTheme.pagePadding)
        .background(AppTheme.surface)
        .overlay(alignment: .bottom) {
            Divider()
                .overlay(AppTheme.border)
        }
    }

    private func itemPreview(_ item: ThreadItem) -> some View {
        HStack(spacing: 12) {
            TileImageFallback(item: item)
                .frame(width: 62, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(AppTheme.bodyFont(size: 15))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(2)

                Text("\(item.brand) | \(item.size)")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)

                AvailabilityBadge(status: item.availabilityStatus)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Message \(owner.displayName)", text: $draftMessage, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...3)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )

            Button(action: sendMessage) {
                Text("Send")
                    .font(AppTheme.bodyFont(size: 15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(canSend ? AppTheme.accent : AppTheme.softInk, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(!canSend)
        }
        .padding(AppTheme.pagePadding)
        .background(AppTheme.background)
    }

    private var canSend: Bool {
        !draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendMessage() {
        let trimmedMessage = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }

        messages.append(LocalChatMessage(text: trimmedMessage, isCurrentUser: true))
        draftMessage = ""
    }

    private func messageBubble(_ message: LocalChatMessage) -> some View {
        Text(message.text)
            .font(AppTheme.bodyFont(size: 15))
            .foregroundStyle(message.isCurrentUser ? .white : AppTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                message.isCurrentUser ? AppTheme.accent : AppTheme.surface,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(message.isCurrentUser ? .clear : AppTheme.border, lineWidth: 1)
            )
            .frame(maxWidth: .infinity, alignment: message.isCurrentUser ? .trailing : .leading)
    }

    private var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }
}

private struct LocalChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isCurrentUser: Bool
}

struct DMChatView_Previews: PreviewProvider {
    static var previews: some View {
        DMChatView(owner: SampleData.users[1], item: SampleData.threadItems[0])
    }
}
