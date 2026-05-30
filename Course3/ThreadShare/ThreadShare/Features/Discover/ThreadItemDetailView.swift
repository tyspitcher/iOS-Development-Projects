//
//  ThreadItemDetailView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

struct ThreadItemDetailView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFieldFocused: Bool
    @State private var isShowingBorrowRequest = false
    @State private var isShowingDM = false
    @State private var isShowingComments = false
    @State private var didTapTagFriend = false
    @State private var isShowingRequestSentAlert = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingReportConfirmation = false
    @State private var isShowingReportSubmitted = false
    @State private var isShowingBlockConfirmation = false
    @State private var isShowingBlockCompleted = false
    @State private var commentDraft = ""

    let item: ThreadItem

    private var viewModel: ThreadItemDetailViewModel {
        ThreadItemDetailViewModel(appState: appState, item: item)
    }

    private var currentItem: ThreadItem {
        viewModel.currentItem
    }

    private var owner: UserProfile? {
        viewModel.owner
    }

    private var isOwnedByCurrentUser: Bool {
        viewModel.isOwnedByCurrentUser
    }

    private var borrowMessage: String {
        viewModel.borrowMessage
    }

    private var canRequestBorrow: Bool {
        viewModel.canRequestBorrow
    }

    private var shouldShowConnectionActions: Bool {
        viewModel.shouldShowConnectionActions
    }

    private var canOwnerToggleAvailability: Bool {
        viewModel.canOwnerToggleAvailability
    }

    private var comments: [ThreadItemComment] {
        viewModel.comments
    }

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    heroImage
                    shopLinkCard
                    titleCard
                    actionRow
                    detailsCard
                }
                .padding(AppTheme.pagePadding)
            }
        }
        .navigationTitle("Item Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $isShowingBorrowRequest) {
            BorrowRequestSheet(item: currentItem, owner: owner) {
                isShowingRequestSentAlert = true
            }
            .environmentObject(appState)
        }
        .sheet(isPresented: $isShowingDM) {
            DMChatView(owner: owner ?? fallbackOwner, item: currentItem)
                .environmentObject(appState)
        }
        .sheet(isPresented: $isShowingComments) {
            NavigationStack {
                commentsCard
                    .padding(AppTheme.pagePadding)
                    .background(AppTheme.background)
                    .navigationTitle("Comments")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                isShowingComments = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Request sent", isPresented: $isShowingRequestSentAlert) {
            Button("Done", role: .cancel) {}
        } message: {
            Text("Your borrow request was sent.")
        }
        .alert("Delete item?", isPresented: $isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if viewModel.deleteItem() {
                    dismiss()
                }
            }
        } message: {
            Text("This removes the item from your closet and clears related borrow activity.")
        }
        .alert("Report item?", isPresented: $isShowingReportConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Submit Report", role: .destructive) {
                submitReport()
                isShowingReportSubmitted = true
            }
        } message: {
            Text("This sends a moderation report for review.")
        }
        .alert("Report submitted", isPresented: $isShowingReportSubmitted) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Thanks. Your report has been submitted for review.")
        }
        .alert("Block user?", isPresented: $isShowingBlockConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Block User", role: .destructive) {
                if viewModel.blockOwner() {
                    isShowingBlockCompleted = true
                }
            }
        } message: {
            Text("Blocking limits visibility and interactions in ThreadShare. Their items will be hidden from your feed, and they will no longer appear in friend search where practical.")
        }
        .alert("User blocked", isPresented: $isShowingBlockCompleted) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("This user’s content and social surfaces will be limited in ThreadShare.")
        }
    }

    private var fallbackOwner: UserProfile {
        UserProfile(
            displayName: "ThreadShare Owner",
            username: "threadshare",
            bio: "ThreadShare member",
            avatarImageName: "person.crop.circle.fill",
            city: "ThreadShare",
            relationship: .publicUser,
            visibility: .publicProfile,
            followerCount: 0,
            followingCount: 0
        )
    }

    private var heroImage: some View {
        DetailHeroImage(item: currentItem)
            .frame(maxWidth: .infinity)
            .aspectRatio(1 / ThreadItemImageSizing.heightRatio(for: currentItem), contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(AppTheme.strongBorder, lineWidth: 1)
            )
            .overlay(alignment: .bottomTrailing) {
                likeButton
                    .padding(14)
            }
            .overlay(alignment: .bottomLeading) {
                HStack(spacing: 8) {
                    AvailabilityBadge(status: currentItem.availabilityStatus)

                    if let owner, !isOwnedByCurrentUser {
                        RelationshipBadge(relationship: owner.relationship)
                    }
                }
                .padding(14)
            }
            .overlay(alignment: .topLeading) {
                if currentItem.isRecentlyAdded {
                    RecentlyAddedBadge(title: "Recently Added")
                        .padding(14)
                }
            }
            .shadow(color: AppTheme.softShadow, radius: 20, x: 0, y: 12)
    }

    @ViewBuilder
    private var shopLinkCard: some View {
        if let purchaseLink = currentItem.purchaseLink {
            Link(destination: purchaseLink) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "bag.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                        .frame(width: 34, height: 34)
                        .background(AppTheme.accentSoft, in: Circle())

                    VStack(alignment: .leading, spacing: 3) {
                        Text(viewModel.shopButtonTitle)
                            .font(AppTheme.titleFont(size: 18))
                            .foregroundStyle(AppTheme.ink)

                        Text(viewModel.shopButtonSubtitle)
                            .font(AppTheme.bodyFont(size: 12))
                            .foregroundStyle(AppTheme.mutedInk)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.accent)
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 8)
            }
            .buttonStyle(.plain)
        }
    }

    private var likeButton: some View {
        Button {
            viewModel.toggleLike()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: currentItem.isLikedByCurrentUser ? "heart.fill" : "heart")
                Text("\(currentItem.likesCount)")
            }
            .font(AppTheme.bodyFont(size: 15))
            .foregroundStyle(currentItem.isLikedByCurrentUser ? AppTheme.accent : AppTheme.ink)
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(AppTheme.surface, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.strongBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(currentItem.isLikedByCurrentUser ? "Unlike item" : "Like item")
    }

    private var titleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let owner, !isOwnedByCurrentUser {
                ownerRow(owner)
            }

            if let owner, shouldShowConnectionActions {
                connectionActions(for: owner)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(currentItem.title)
                    .font(AppTheme.titleFont(size: 32))
                    .foregroundStyle(AppTheme.ink)

                Text(currentItem.notes)
                    .font(AppTheme.bodyFont(size: 16))
                    .foregroundStyle(AppTheme.ink.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !isOwnedByCurrentUser {
                if canRequestBorrow {
                    PrimaryButton(title: "Request to Borrow", systemImage: "bag.badge.plus") {
                        isShowingBorrowRequest = true
                    }
                } else {
                    SecondaryButton(title: borrowMessage, systemImage: "lock.fill", isDisabled: true) {}
                }
            } else {
                ownerItemActions
            }
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: AppTheme.softShadow, radius: 16, x: 0, y: 10)
    }

    private var deleteItemButton: some View {
        Button {
            isShowingDeleteConfirmation = true
        } label: {
            Label("Delete Item", systemImage: "trash.fill")
                .font(AppTheme.bodyFont(size: 16))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                        .stroke(.red.opacity(0.28), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Delete item from my closet")
    }

    private var ownerItemActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                _ = viewModel.toggleOwnedAvailability()
            } label: {
                Label(viewModel.availabilityToggleTitle, systemImage: viewModel.availabilityToggleIcon)
                    .font(AppTheme.bodyFont(size: 16))
                    .foregroundStyle(canOwnerToggleAvailability ? AppTheme.ink : AppTheme.mutedInk)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canOwnerToggleAvailability)
            .accessibilityLabel(viewModel.availabilityToggleTitle)

            Text(viewModel.availabilityHelperText)
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)

            deleteItemButton
        }
    }

    private var actionRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if !isOwnedByCurrentUser {
                    detailActionButton(title: "Message Owner", systemImage: "message.fill") {
                        isShowingDM = true
                    }
                }

                detailActionButton(title: "Comment", systemImage: "bubble.left.fill") {
                    isShowingComments = true
                }
            }

            detailActionButton(title: "Tag Friend", systemImage: "person.crop.circle.badge.plus") {
                didTapTagFriend.toggle()
            }

            if !isOwnedByCurrentUser {
                detailActionButton(title: "Report Item", systemImage: "flag.fill") {
                    isShowingReportConfirmation = true
                }

                if viewModel.canBlockOwner {
                    detailActionButton(title: "Block User", systemImage: "hand.raised.fill") {
                        isShowingBlockConfirmation = true
                    }
                }
            }

            if didTapTagFriend {
                Text("Friend tag added.")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func submitReport() {
        appState.submitItemReport(
            itemID: currentItem.id,
            reason: .inappropriate,
            details: "Submitted from item detail report action."
        )
    }

    private var commentsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                SectionTitle("Comments")
                Spacer()
                Text("\(comments.count)")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            commentComposer

            if comments.isEmpty {
                Text("No comments yet. Start the conversation on this item.")
                    .font(AppTheme.bodyFont(size: 13))
                    .foregroundStyle(AppTheme.mutedInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(comments.enumerated()), id: \.element.id) { index, comment in
                        commentRow(comment)

                        if index < comments.count - 1 {
                            Divider()
                                .overlay(AppTheme.border)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private var commentComposer: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Add a comment", text: $commentDraft, axis: .vertical)
                .font(AppTheme.bodyFont(size: 15))
                .textFieldStyle(.plain)
                .lineLimit(1...4)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .focused($isCommentFieldFocused)

            Button("Post") {
                guard viewModel.addComment(body: commentDraft) != nil else { return }
                commentDraft = ""
                isCommentFieldFocused = false
            }
            .font(AppTheme.bodyFont(size: 15))
            .foregroundStyle(canPostComment ? AppTheme.accent : AppTheme.mutedInk)
            .disabled(!canPostComment)
        }
    }

    private var canPostComment: Bool {
        commentDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func commentRow(_ comment: ThreadItemComment) -> some View {
        let author = viewModel.author(for: comment)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                UserAvatarView(imageName: author?.avatarImageName ?? "person.crop.circle.fill", size: 34)

                VStack(alignment: .leading, spacing: 3) {
                    Text(author?.displayName ?? "ThreadShare Member")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.ink)

                    Text(author.map { "@\($0.username)" } ?? "Unknown user")
                        .font(AppTheme.bodyFont(size: 12))
                        .foregroundStyle(AppTheme.mutedInk)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(viewModel.formattedCreatedDate(for: comment))
                        .font(AppTheme.bodyFont(size: 11))
                        .foregroundStyle(AppTheme.mutedInk)

                    if viewModel.canDeleteComment(comment) {
                        Button(role: .destructive) {
                            _ = viewModel.deleteComment(comment.id)
                        } label: {
                            Image(systemName: "trash")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Delete comment")
                    }
                }
            }

            Text(comment.body)
                .font(AppTheme.bodyFont(size: 14))
                .foregroundStyle(AppTheme.ink.opacity(0.84))
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle("Details")

            VStack(spacing: 0) {
                detailRow("Brand", currentItem.brand)
                detailRow("Size", currentItem.size)
                detailRow("Fits like", currentItem.fitsLike)
                detailRow("Condition", currentItem.condition.displayName)
                detailRow("Color", currentItem.colorName)
                detailRow("Category", currentItem.category.displayName)
                detailRow("Occasion", currentItem.occasions.map(\.displayName).joined(separator: ", "))
                detailRow("Where purchased", currentItem.wherePurchased)
                detailRow("Availability", currentItem.availabilityStatus.displayName, showsDivider: false)
            }
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
    }

    private func ownerRow(_ owner: UserProfile) -> some View {
        HStack(spacing: 12) {
            UserAvatarView(imageName: owner.avatarImageName, size: 56)

            VStack(alignment: .leading, spacing: 4) {
                NavigationLink {
                    UserProfileDetailView(user: owner)
                } label: {
                    Text(owner.displayName)
                        .font(AppTheme.titleFont(size: 20))
                        .foregroundStyle(AppTheme.ink)
                }
                .buttonStyle(.plain)

                Text("@\(owner.username)")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            Spacer()

            if !isOwnedByCurrentUser {
                RelationshipBadge(relationship: owner.relationship)
            }
        }
    }

    private func connectionActions(for owner: UserProfile) -> some View {
        HStack(spacing: 10) {
            SecondaryButton(
                title: owner.isFollowedByCurrentUser ? "Following" : "Follow",
                systemImage: owner.isFollowedByCurrentUser ? "checkmark.circle.fill" : "plus.circle"
            ) {
                viewModel.followOwnerIfNeeded()
            }

            friendRequestButton
        }
    }

    private var friendRequestButton: some View {
        let state = viewModel.friendConnectionState
        let isDisabled = state != .addFriend

        return Button {
            viewModel.requestFriendIfNeeded()
        } label: {
            Label(friendRequestTitle(for: state), systemImage: friendRequestIcon(for: state))
                .font(AppTheme.bodyFont(size: 16))
                .foregroundStyle(friendRequestForeground(for: state))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(friendRequestBackground(for: state), in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                        .stroke(friendRequestBorder(for: state), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .accessibilityLabel(friendRequestTitle(for: state))
    }

    private func friendRequestTitle(for state: FriendConnectionState) -> String {
        switch state {
        case .addFriend: "Request Friend"
        case .requested: "Request Sent"
        case .incomingRequest: "Requested You"
        case .friends: "Friends"
        }
    }

    private func friendRequestIcon(for state: FriendConnectionState) -> String {
        switch state {
        case .addFriend: "person.badge.plus"
        case .requested: "paperplane.fill"
        case .incomingRequest: "person.crop.circle.badge.questionmark"
        case .friends: "person.2.fill"
        }
    }

    private func friendRequestForeground(for state: FriendConnectionState) -> Color {
        switch state {
        case .addFriend: AppTheme.ink
        case .requested, .incomingRequest: AppTheme.accent
        case .friends: AppTheme.ink
        }
    }

    private func friendRequestBackground(for state: FriendConnectionState) -> Color {
        switch state {
        case .addFriend, .friends: AppTheme.surface
        case .requested, .incomingRequest: AppTheme.accentSoft
        }
    }

    private func friendRequestBorder(for state: FriendConnectionState) -> Color {
        switch state {
        case .addFriend, .friends: AppTheme.border
        case .requested, .incomingRequest: AppTheme.accent.opacity(0.45)
        }
    }

    private func detailActionButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(AppTheme.bodyFont(size: 15))
                .foregroundStyle(AppTheme.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func detailRow(_ label: String, _ value: String, showsDivider: Bool = true) -> some View {
        VStack(spacing: 0) {
            detailRowContent(label: label, value: value)

            if showsDivider {
                Divider()
                    .overlay(AppTheme.border)
            }
        }
    }

    private func detailRowContent(label: String, value: String, showsChevron: Bool = false) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(AppTheme.bodyFont(size: 15))
                .foregroundStyle(AppTheme.mutedInk)

            Spacer()

            Text(value)
                .font(AppTheme.bodyFont(size: 15))
                .foregroundStyle(AppTheme.ink)
                .multilineTextAlignment(.trailing)

            if showsChevron {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(.vertical, 12)
    }
}

private struct DetailHeroImage: View {
    let item: ThreadItem

    var body: some View {
        Group {
            if let imageURL = ThreadItemImageStore.imageURL(for: item.imageName) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
        }
        .accessibilityLabel("\(item.title) image")
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.color(for: item.category).opacity(0.92),
                    AppTheme.color(for: item.category).opacity(0.45),
                    AppTheme.accentSoft.opacity(0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: iconName)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var iconName: String {
        switch item.category {
        case .tops: "tshirt"
        case .bottoms: "figure.stand"
        case .dresses: "sparkles"
        case .shoes: "shoeprints.fill"
        case .sweaters: "hanger"
        case .accessories: "handbag"
        }
    }
}

struct ThreadItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ThreadItemDetailView(item: SampleData.threadItems[0])
                .environmentObject(AppState())
        }
    }
}
