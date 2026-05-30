//
//  BorrowViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum BorrowPersonRole {
    case owner
    case borrower

    var label: String {
        switch self {
        case .owner: "Owner"
        case .borrower: "Borrower"
        }
    }
}

struct BorrowViewModel {
    let appState: AppState

    var requestsSent: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter { $0.requesterID == currentUser.id && $0.status == .pending }
    }

    var borrowedByMe: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter { $0.requesterID == currentUser.id && $0.status == .approved }
    }

    var awaitingOwnerConfirmationAsBorrower: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter {
            $0.requesterID == currentUser.id && $0.status == .returnPendingOwnerConfirmation
        }
    }

    var lendingOut: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter {
            $0.ownerID == currentUser.id && ($0.status == .pending || $0.status == .approved)
        }
    }

    var returnConfirmationsNeededAsOwner: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter {
            $0.ownerID == currentUser.id && $0.status == .returnPendingOwnerConfirmation
        }
    }

    var isEmpty: Bool {
        requestsSent.isEmpty &&
        borrowedByMe.isEmpty &&
        awaitingOwnerConfirmationAsBorrower.isEmpty &&
        lendingOut.isEmpty &&
        returnConfirmationsNeededAsOwner.isEmpty
    }

    private var sortedRequests: [BorrowRequest] {
        var seen = Set<BorrowRequest.ID>()
        return appState.borrowRequests
            .sorted { $0.createdAt > $1.createdAt }
            .filter { seen.insert($0.id).inserted }
    }

    func item(for request: BorrowRequest) -> ThreadItem? {
        appState.threadItems.first { $0.id == request.itemID }
    }

    func personName(for request: BorrowRequest, role: BorrowPersonRole) -> String {
        let personID = role == .owner ? request.ownerID : request.requesterID
        return appState.users.first { $0.id == personID }?.displayName ?? "ThreadShare User"
    }

    func markReturnedByBorrower(_ request: BorrowRequest) {
        appState.borrowerMarkedRequestReturned(request.id)
    }

    func confirmReturnedByOwner(_ request: BorrowRequest) {
        appState.ownerConfirmedRequestReturned(request.id)
    }

    func approveRequest(_ request: BorrowRequest) {
        appState.updateBorrowRequest(request.id, status: .approved)
    }

    func declineRequest(_ request: BorrowRequest) {
        appState.updateBorrowRequest(request.id, status: .declined)
    }

    func reminder(for request: BorrowRequest) -> BorrowReturnReminder? {
        appState.returnReminder(for: request.id)
    }

    func setReminder(_ cadence: ReturnReminderCadence?, for request: BorrowRequest) {
        appState.setReturnReminder(for: request, cadence: cadence)
    }

    func canSetReminder(_ request: BorrowRequest) -> Bool {
        guard let currentUser = appState.currentUser else { return false }
        return request.requesterID == currentUser.id && request.status == .approved
    }

    func canMarkReturnedByBorrower(_ request: BorrowRequest) -> Bool {
        guard let currentUser = appState.currentUser else { return false }
        return request.requesterID == currentUser.id && request.status == .approved
    }

    func canConfirmReturnedByOwner(_ request: BorrowRequest) -> Bool {
        guard let currentUser = appState.currentUser else { return false }
        return request.ownerID == currentUser.id &&
            (request.status == .approved || request.status == .returnPendingOwnerConfirmation)
    }

    func canApproveOrDecline(_ request: BorrowRequest) -> Bool {
        guard let currentUser = appState.currentUser else { return false }
        return request.ownerID == currentUser.id && request.status == .pending
    }
}
