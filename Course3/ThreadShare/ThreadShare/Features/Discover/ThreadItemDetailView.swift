//
//  ThreadItemDetailView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI
#if canImport(SafariServices)
import SafariServices
#endif

struct ThreadItemDetailView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @FocusState private var isCommentFieldFocused: Bool
    @State private var isShowingBorrowRequest = false
    @State private var isShowingDM = false
    @State private var isShowingComments = false
    @State private var isShowingPurchaseLinkSheet = false
    @State private var isShowingLinkReportSheet = false
    @State private var isShowingFriendTagSheet = false
    @State private var isShowingFriendTaggedConfirmation = false
    @State private var isShowingRequestSentAlert = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingReportConfirmation = false
    @State private var isShowingReportSubmitted = false
    @State private var selectedLinkReportReason: ItemReportReason = .brokenLink
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
                    moderationActions
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
        .sheet(isPresented: $isShowingPurchaseLinkSheet) {
            if let purchaseLink = currentItem.purchaseLink {
                purchaseLinkSheet(for: purchaseLink)
            } else {
                EmptyView()
            }
        }
        .sheet(isPresented: $isShowingLinkReportSheet) {
            if let purchaseLink = currentItem.purchaseLink {
                linkReportSheet(for: purchaseLink)
            } else {
                EmptyView()
            }
        }
        .sheet(isPresented: $isShowingFriendTagSheet) {
            NavigationStack {
                FriendListView(selectionAction: { friend in
                    guard appState.tagFriend(friend.id, for: currentItem) else { return }
                    isShowingFriendTagSheet = false
                    isShowingFriendTaggedConfirmation = true
                })
                .environmentObject(appState)
                .navigationTitle("Tag Friend")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $isShowingComments) {
            NavigationStack {
                commentsSheet
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
            Button("Delete Item", role: .destructive) {
                if viewModel.deleteItem() {
                    dismiss()
                }
            }
        } message: {
            Text("This will remove the item from your closet and clear related borrow activity.")
        }
        .alert("Report item?", isPresented: $isShowingReportConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Submit Report", role: .destructive) {
                submitReport()
                isShowingReportSubmitted = true
            }
        } message: {
            Text("This will send a moderation report for review.")
        }
        .alert("Report submitted", isPresented: $isShowingReportSubmitted) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Thanks. Your report has been submitted for review.")
        }
        .alert("Friend tagged", isPresented: $isShowingFriendTaggedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your friend has been tagged and will be notified.")
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
            .clipShape(RoundedRectangle(cornerRadius: 33, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 33, style: .continuous)
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
            Button {
                isShowingPurchaseLinkSheet = true
            } label: {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "safari.fill")
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
            .accessibilityLabel("Open buy now listing")
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
                isShowingFriendTagSheet = true
            }
        }
    }

    private var moderationActions: some View {
        guard !isOwnedByCurrentUser else {
            return AnyView(EmptyView())
        }

        return AnyView(
            secondaryModerationButton(title: "Report Item", systemImage: "flag.fill") {
                isShowingReportConfirmation = true
            }
        )
    }

    private func secondaryModerationButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(AppTheme.bodyFont(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.mutedInk)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(AppTheme.surface.opacity(0.8), in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.7), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func submitReport() {
        appState.submitItemReport(
            itemID: currentItem.id,
            reason: .inappropriate,
            details: "Submitted from item detail report action."
        )
    }

    private func submitLinkReport(for purchaseLink: URL) {
        let details = [
            "Reported from item detail purchase link.",
            "Reason: \(selectedLinkReportReason.rawValue)",
            "Item: \(currentItem.title)",
            "Brand: \(currentItem.brand)",
            "Purchase link: \(purchaseLink.absoluteString)"
        ]
        .joined(separator: "\n")

        appState.submitItemReport(
            itemID: currentItem.id,
            reason: selectedLinkReportReason,
            details: details
        )

        if let mailtoURL = makeDeveloperMailtoURL(for: purchaseLink) {
            openURL(mailtoURL)
        }
    }

    private func makeDeveloperMailtoURL(for purchaseLink: URL) -> URL? {
        let subject = "ThreadShare link report: \(currentItem.title)"
        let body = """
        Link report reason: \(selectedLinkReportReason.rawValue)

        Item: \(currentItem.title)
        Brand: \(currentItem.brand)
        Purchase link: \(purchaseLink.absoluteString)

        Additional context:
        """

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "tyspitcher@gmail.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body)
        ]
        return components.url
    }

    @ViewBuilder
    private func purchaseLinkSheet(for purchaseLink: URL) -> some View {
        NavigationStack {
            safariWebView(for: purchaseLink)
                .navigationTitle("Buy Now Online")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Report Link") {
                            isShowingPurchaseLinkSheet = false
                            isShowingLinkReportSheet = true
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Open in Safari") {
                            openURL(purchaseLink)
                        }
                    }

                    ToolbarItem(placement: .bottomBar) {
                        Button("Done") {
                            isShowingPurchaseLinkSheet = false
                        }
                    }
                }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func safariWebView(for url: URL) -> some View {
#if canImport(SafariServices)
        SafariWebView(url: url)
#else
        VStack(spacing: 14) {
            Image(systemName: "safari")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(AppTheme.accent)

            Text("Web preview unavailable on this platform.")
                .font(AppTheme.bodyFont(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.ink)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
#endif
    }

    private func linkReportSheet(for purchaseLink: URL) -> some View {
        NavigationStack {
            Form {
                Section {
                    Text("Choose the best reason for reporting this link.")
                        .font(AppTheme.bodyFont(size: 14))
                        .foregroundStyle(AppTheme.mutedInk)
                }

                Section("Report Reason") {
                    Picker("Reason", selection: $selectedLinkReportReason) {
                        ForEach(ItemReportReason.linkReportCases) { reason in
                            Text(reason.rawValue).tag(reason)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section {
                    Text("We will submit the report and email the developer with the link details.")
                        .font(AppTheme.bodyFont(size: 13))
                        .foregroundStyle(AppTheme.mutedInk)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Report Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isShowingLinkReportSheet = false
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Send") {
                        submitLinkReport(for: purchaseLink)
                        isShowingLinkReportSheet = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var commentsSheet: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.tightSpacing) {
                    HStack {
                        SectionTitle("Comments")
                        Spacer()
                        Text("\(comments.count)")
                            .font(AppTheme.bodyFont(size: 12, weight: .medium))
                            .foregroundStyle(AppTheme.mutedInk)
                    }

                    if comments.isEmpty {
                        Text("No comments yet. Start the conversation on this item.")
                            .font(AppTheme.bodyFont(size: 13, weight: .medium))
                            .foregroundStyle(AppTheme.mutedInk)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppTheme.tightSpacing)
                            .padding(.vertical, AppTheme.xSmallSpacing)
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
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                                .stroke(AppTheme.border, lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, AppTheme.pagePadding)
                .padding(.top, AppTheme.pagePadding)
                .padding(.bottom, AppTheme.cardPadding)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            Divider()
                .overlay(AppTheme.border)

            commentComposer
                .padding(AppTheme.pagePadding)
                .background(AppTheme.surface)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppTheme.background)
    }

    private var commentComposer: some View {
        HStack(alignment: .bottom, spacing: AppTheme.tightSpacing) {
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
            .font(AppTheme.bodyFont(size: 15, weight: .semibold))
            .foregroundStyle(canPostComment ? AppTheme.accent : AppTheme.mutedInk)
            .disabled(!canPostComment)
        }
        .padding(.horizontal, AppTheme.tightSpacing)
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
        .padding(.horizontal, AppTheme.tightSpacing)
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

private extension ItemReportReason {
    static var linkReportCases: [ItemReportReason] {
        [.brokenLink, .linkInappropriate, .notCorrectItem, .other]
    }
}

#if canImport(SafariServices)
private struct SafariWebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
#endif
