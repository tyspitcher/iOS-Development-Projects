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

    private var viewModel: BorrowViewModel {
        BorrowViewModel(appState: appState)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header

                        if viewModel.isEmpty {
                            EmptyStateView(
                                title: "No borrow activity yet",
                                message: "Requests you send, pieces you borrow, and items you lend out will live here.",
                                systemImage: "bag"
                            )
                        } else {
                            BorrowSection(title: "Requests Sent", requests: viewModel.requestsSent, emptyMessage: "No pending requests sent.") { request in
                                row(for: request, personRole: .owner)
                            }

                            BorrowSection(title: "Borrowed By Me", requests: viewModel.borrowedByMe, emptyMessage: "No approved borrowed pieces yet.") { request in
                                row(for: request, personRole: .owner)
                            }

                            BorrowSection(
                                title: "Awaiting Owner Confirmation",
                                requests: viewModel.awaitingOwnerConfirmationAsBorrower,
                                emptyMessage: "No returns waiting for owner confirmation."
                            ) { request in
                                row(for: request, personRole: .owner)
                            }

                            BorrowSection(title: "Lending Out", requests: viewModel.lendingOut, emptyMessage: "No one is borrowing from your closet yet.") { request in
                                row(for: request, personRole: .borrower)
                            }

                            BorrowSection(
                                title: "Return Confirmations Needed",
                                requests: viewModel.returnConfirmationsNeededAsOwner,
                                emptyMessage: "No borrower-marked returns need your confirmation."
                            ) { request in
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
        let item = viewModel.item(for: request)
        let personName = viewModel.personName(for: request, role: personRole)

        return BorrowRequestRow(
            request: request,
            item: item,
            personName: personName,
            personRole: personRole,
            reminder: viewModel.reminder(for: request),
            now: Date(),
            onOpenItem: item.map { tappedItem in
                { selectedItem = tappedItem }
            },
            onMarkReturnedByBorrower: viewModel.canMarkReturnedByBorrower(request)
                ? { viewModel.markReturnedByBorrower(request) }
                : nil,
            onConfirmReturnedByOwner: viewModel.canConfirmReturnedByOwner(request)
                ? { viewModel.confirmReturnedByOwner(request) }
                : nil,
            onApproveRequest: viewModel.canApproveOrDecline(request)
                ? { viewModel.approveRequest(request) }
                : nil,
            onDeclineRequest: viewModel.canApproveOrDecline(request)
                ? { viewModel.declineRequest(request) }
                : nil,
            onSetReminder: viewModel.canSetReminder(request)
                ? { cadence in viewModel.setReminder(cadence, for: request) }
                : nil
        )
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
    let reminder: BorrowReturnReminder?
    let now: Date
    var onOpenItem: (() -> Void)?
    var onMarkReturnedByBorrower: (() -> Void)?
    var onConfirmReturnedByOwner: (() -> Void)?
    var onApproveRequest: (() -> Void)?
    var onDeclineRequest: (() -> Void)?
    var onSetReminder: ((ReturnReminderCadence?) -> Void)?

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

                if let onSetReminder {
                    reminderMenu(onSetReminder: onSetReminder)
                }

                if let onApproveRequest, let onDeclineRequest {
                    HStack(spacing: 10) {
                        SecondaryButton(title: "Decline", systemImage: "xmark.circle.fill") {
                            onDeclineRequest()
                        }

                        PrimaryButton(title: "Approve", systemImage: "checkmark.circle.fill") {
                            onApproveRequest()
                        }
                    }
                    .padding(.top, 2)
                }

                if let onMarkReturnedByBorrower {
                    SecondaryButton(title: "I Returned This Item", systemImage: "arrow.uturn.backward.circle.fill") {
                        onMarkReturnedByBorrower()
                    }
                    .padding(.top, 2)
                }

                if let onConfirmReturnedByOwner {
                    PrimaryButton(title: "Confirm Returned", systemImage: "checkmark.seal.fill") {
                        onConfirmReturnedByOwner()
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

    private func reminderMenu(onSetReminder: @escaping (ReturnReminderCadence?) -> Void) -> some View {
        Menu {
            Button("One-Time Reminder") {
                onSetReminder(.oneTime)
            }

            Button("Daily Reminder") {
                onSetReminder(.daily)
            }

            if reminder != nil {
                Button("Turn Off Reminder", role: .destructive) {
                    onSetReminder(nil)
                }
            }
        } label: {
            Label(reminderMenuTitle, systemImage: "bell.badge")
                .font(AppTheme.bodyFont(size: 13).weight(.semibold))
                .foregroundStyle(AppTheme.ink)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background(AppTheme.background, in: RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.smallCornerRadius, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
        }
        .padding(.top, 2)
    }

    private var reminderMenuTitle: String {
        guard let reminder else { return "Set Return Reminder" }
        return "\(reminder.cadence.displayName) Reminder"
    }

    private var reminderText: String? {
        if request.status == .returnPendingOwnerConfirmation {
            let timestamp = request.borrowerMarkedReturnedAt ?? request.createdAt
            let components = Calendar.current.dateComponents([.day], from: timestamp, to: now)
            let days = max(0, components.day ?? 0)
            return days == 0
                ? "Marked returned today. Waiting for owner confirmation."
                : "Marked returned \(days) day\(days == 1 ? "" : "s") ago. Waiting for owner confirmation."
        }
        guard let reminder else { return request.status == .returned ? "Returned" : nil }
        return "Next reminder \(reminder.nextReminderAt.formatted(date: .abbreviated, time: .shortened))"
    }

    private var statusColor: Color {
        switch request.status {
        case .pending: AppTheme.clay
        case .approved: AppTheme.moss
        case .returnPendingOwnerConfirmation: AppTheme.accent
        case .declined: AppTheme.softInk
        case .returned: AppTheme.accent
        }
    }

    private var statusIcon: String {
        switch request.status {
        case .pending: "clock.fill"
        case .approved: "checkmark.circle.fill"
        case .returnPendingOwnerConfirmation: "hourglass.badge.exclamationmark"
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
