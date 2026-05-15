//
//  ThreadItemDetailView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct ThreadItemDetailView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingBorrowRequest = false
    @State private var isShowingDM = false
    @State private var didTapComment = false
    @State private var didTapTagFriend = false
    @State private var isShowingRequestSentAlert = false
    @State private var isShowingDeleteConfirmation = false

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
        }
        .alert("Request sent", isPresented: $isShowingRequestSentAlert) {
            Button("Done", role: .cancel) {}
        } message: {
            Text("Your borrow request was saved locally for the demo.")
        }
        .alert("Delete item?", isPresented: $isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if viewModel.deleteItem() {
                    dismiss()
                }
            }
        } message: {
            Text("This removes the item from your closet and clears any related local borrow activity.")
        }
    }

    private var fallbackOwner: UserProfile {
        UserProfile(
            displayName: "ThreadShare Owner",
            username: "threadshare",
            bio: "Local demo profile",
            avatarImageName: "person.crop.circle.fill",
            city: "Demo",
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
            .frame(maxHeight: 500)
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
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
            .background(.white.opacity(0.92), in: Capsule())
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
                deleteItemButton
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

    private var actionRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if !isOwnedByCurrentUser {
                    detailActionButton(title: "Message Owner", systemImage: "message.fill") {
                        isShowingDM = true
                    }
                }

                detailActionButton(title: "Comment", systemImage: "bubble.left.fill") {
                    didTapComment.toggle()
                }
            }

            detailActionButton(title: "Tag Friend", systemImage: "person.crop.circle.badge.plus") {
                didTapTagFriend.toggle()
            }

            if didTapComment || didTapTagFriend {
                Text(didTapComment ? "Comment saved locally for the demo." : "Friend tag saved locally for the demo.")
                    .font(AppTheme.bodyFont(size: 12))
                    .foregroundStyle(AppTheme.mutedInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
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

            SecondaryButton(
                title: owner.relationship == .friend ? "Friends" : "Request Friend",
                systemImage: owner.relationship == .friend ? "person.2.fill" : "person.badge.plus"
            ) {
                viewModel.requestFriendIfNeeded()
            }
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

            if let uiImage = ThreadItemImageStore.uiImage(named: item.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
        }
        .accessibilityLabel("\(item.title) image")
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
