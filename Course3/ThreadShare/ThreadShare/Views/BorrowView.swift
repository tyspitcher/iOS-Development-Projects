//
//  BorrowView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

struct BorrowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedItem: ThreadItem?

    private var requestsSent: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter { $0.requesterID == currentUser.id && $0.status == .pending }
    }

    private var borrowedByMe: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter { $0.requesterID == currentUser.id && $0.status == .approved }
    }

    private var lendingOut: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter {
            $0.ownerID == currentUser.id &&
            ($0.status == .pending || $0.status == .approved)
        }
    }

    private var sortedRequests: [BorrowRequest] {
        appState.borrowRequests.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        
                        header

                        if appState.borrowRequests.isEmpty {
                            EmptyStateView(
                                title: "No borrow activity yet",
                                message: "Requests you send, pieces you borrow, and items you lend out will live here.",
                                systemImage: "bag"
                            )
                        } else {
                            BorrowSection(title: "Requests Sent", requests: requestsSent, emptyMessage: "No pending requests sent.") { request in
                                row(for: request, personRole: .owner)
                            }

                            BorrowSection(title: "Borrowed By Me", requests: borrowedByMe, emptyMessage: "No approved borrowed pieces yet.") { request in
                                row(for: request, personRole: .owner)
                            }

                            BorrowSection(title: "Lending Out", requests: lendingOut, emptyMessage: "No one is borrowing from your closet yet.") { request in
                                row(for: request, personRole: .borrower)
                            }
                        }
                    }
                    .padding(AppTheme.pagePadding)
                }
            }
            .navigationTitle("")
            #if os(iOS)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            #endif
            .navigationDestination(item: $selectedItem) { item in
                ThreadItemDetailView(item: item)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ThreadShare")
                .font(AppTheme.brandFont(size: 40))
                .fontWeight(.bold)
                .foregroundStyle(AppTheme.ink)

            Text("Borrow Board")
                .font(AppTheme.titleFont(size: 26))
                .foregroundStyle(AppTheme.ink)

            Text("Track requests, returns, and lending plans in one clean place.")
                .font(AppTheme.bodyFont(size: 15))
                .foregroundStyle(AppTheme.mutedInk)
        }
    }

    private func row(for request: BorrowRequest, personRole: BorrowPersonRole) -> some View {
        let item = appState.threadItems.first { $0.id == request.itemID }
        let personID = personRole == .owner ? request.ownerID : request.requesterID
        let person = appState.users.first { $0.id == personID }

        return BorrowRequestRow(
            request: request,
            item: item,
            personName: person?.displayName ?? "ThreadShare User",
            personRole: personRole,
            onOpenItem: item.map { tappedItem in
                { selectedItem = tappedItem }
            },
            onMarkReturned: personRole == .borrower && request.status == .approved
                ? { appState.updateBorrowRequest(request.id, status: .returned) }
                : nil
        )
    }
}

private enum BorrowPersonRole {
    case owner
    case borrower

    var label: String {
        switch self {
        case .owner: "Owner"
        case .borrower: "Borrower"
        }
    }
}

private struct BorrowSection<RowContent: View>: View {
    let title: String
    let requests: [BorrowRequest]
    let emptyMessage: String
    let rowContent: (BorrowRequest) -> RowContent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title)

            if requests.isEmpty {
                Text(emptyMessage)
                    .font(AppTheme.bodyFont(size: 15))
                    .foregroundStyle(AppTheme.mutedInk)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                            .stroke(AppTheme.border, lineWidth: 1)
                    )
            } else {
                VStack(spacing: 12) {
                    ForEach(requests) { request in
                        rowContent(request)
                    }
                }
            }
        }
    }
}

private struct BorrowRequestRow: View {
    let request: BorrowRequest
    let item: ThreadItem?
    let personName: String
    let personRole: BorrowPersonRole
    var onOpenItem: (() -> Void)?
    var onMarkReturned: (() -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 7) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item?.title ?? "Borrowed piece")
                            .font(AppTheme.titleFont(size: 20))
                            .foregroundStyle(AppTheme.ink)
                            .lineLimit(2)

                        Text("\(personRole.label): \(personName)")
                            .font(AppTheme.bodyFont(size: 15))
                            .foregroundStyle(AppTheme.mutedInk)
                            .lineLimit(1)
                    }

                    Spacer()

                    InfoChip(title: request.status.displayName, systemImage: statusIcon, tint: statusColor)
                }

                HStack(spacing: 8) {
                    InfoChip(title: request.requestedStartDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar", tint: AppTheme.mutedInk)
                    InfoChip(title: request.requestedEndDate.formatted(date: .abbreviated, time: .omitted), systemImage: "arrow.right", tint: AppTheme.mutedInk)
                }

                if let reminderText {
                    Label(reminderText, systemImage: "bell.fill")
                        .font(AppTheme.bodyFont(size: 12))
                        .foregroundStyle(AppTheme.accent)
                        .padding(.top, 2)
                }

                if let onMarkReturned {
                    PrimaryButton(title: "Mark Returned", systemImage: "arrow.uturn.backward.circle.fill") {
                        onMarkReturned()
                    }
                    .padding(.top, 2)
                }
            }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(AppTheme.border, lineWidth: 1)
        )
        .shadow(color: AppTheme.softShadow, radius: 12, x: 0, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .onTapGesture {
            onOpenItem?()
        }
    }

    private var thumbnail: some View {
        Group {
            if let item {
                TileImageFallback(item: item)
            } else {
                ZStack {
                    AppTheme.accentSoft
                    Image(systemName: "bag.fill")
                        .foregroundStyle(AppTheme.accent)
                }
            }
        }
        .frame(width: 72, height: 88)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
    }

    private var reminderText: String? {
        switch request.status {
        case .pending:
            "Follow-up reminder set"
        case .approved:
            "Return reminder set"
        case .declined:
            nil
        case .returned:
            "Returned"
        }
    }

    private var statusColor: Color {
        switch request.status {
        case .pending: AppTheme.clay
        case .approved: AppTheme.moss
        case .declined: AppTheme.softInk
        case .returned: AppTheme.accent
        }
    }

    private var statusIcon: String {
        switch request.status {
        case .pending: "clock.fill"
        case .approved: "checkmark.circle.fill"
        case .declined: "xmark.circle.fill"
        case .returned: "arrow.uturn.backward.circle.fill"
        }
    }
}

struct BorrowView_Previews: PreviewProvider {
    static var previews: some View {
        BorrowView()
            .environmentObject(AppState())
    }
}
