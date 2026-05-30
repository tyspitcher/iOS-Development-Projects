//
//  DMChatView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

struct DMChatView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let owner: UserProfile
    let item: ThreadItem?

    @State private var draftMessage = ""

    private var threadMessages: [DMMessage] {
        appState.conversationMessages(with: owner.id)
    }

    private var firstUnreadMessageID: DMMessage.ID? {
        guard let currentUser = appState.currentUser else { return nil }
        return threadMessages.first {
            $0.senderID == owner.id &&
            $0.recipientID == currentUser.id &&
            !$0.isRead
        }?.id
    }

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

                            if threadMessages.isEmpty {
                                Text("No messages yet. Start the conversation.")
                                    .font(AppTheme.bodyFont(size: 14))
                                    .foregroundStyle(AppTheme.mutedInk)
                            }

                            ForEach(threadMessages) { message in
                                if message.id == firstUnreadMessageID {
                                    unreadDivider
                                }
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
            .task(id: owner.id) {
                appState.markConversationRead(with: owner.id)
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

        _ = appState.sendDirectMessage(
            to: owner.id,
            body: trimmedMessage,
            itemID: item?.id
        )
        draftMessage = ""
    }

    private func messageBubble(_ message: DMMessage) -> some View {
        let isCurrentUser = message.senderID == appState.currentUser?.id

        return Text(message.body)
            .font(AppTheme.bodyFont(size: 15))
            .foregroundStyle(isCurrentUser ? .white : AppTheme.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isCurrentUser ? AppTheme.accent : AppTheme.surface,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isCurrentUser ? .clear : AppTheme.border, lineWidth: 1)
            )
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
    }

    private var unreadDivider: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
            Text("Unread Messages")
                .font(AppTheme.bodyFont(size: 11).weight(.semibold))
                .foregroundStyle(AppTheme.softInk)
                .fixedSize()
            Rectangle()
                .fill(AppTheme.border)
                .frame(height: 1)
        }
        .padding(.vertical, 4)
    }

    private var trailingToolbarPlacement: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .automatic
        #endif
    }
}

struct DMChatView_Previews: PreviewProvider {
    static var previews: some View {
        DMChatView(owner: SampleData.users[1], item: SampleData.threadItems[0])
            .environmentObject(AppState())
    }
}
