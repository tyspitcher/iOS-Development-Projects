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

    var lendingOut: [BorrowRequest] {
        guard let currentUser = appState.currentUser else { return [] }
        return sortedRequests.filter {
            $0.ownerID == currentUser.id && ($0.status == .pending || $0.status == .approved)
        }
    }

    var isEmpty: Bool {
        appState.borrowRequests.isEmpty
    }

    private var sortedRequests: [BorrowRequest] {
        appState.borrowRequests.sorted { $0.createdAt > $1.createdAt }
    }

    func item(for request: BorrowRequest) -> ThreadItem? {
        appState.threadItems.first { $0.id == request.itemID }
    }

    func personName(for request: BorrowRequest, role: BorrowPersonRole) -> String {
        let personID = role == .owner ? request.ownerID : request.requesterID
        return appState.users.first { $0.id == personID }?.displayName ?? "ThreadShare User"
    }

    func markReturned(_ request: BorrowRequest) {
        appState.updateBorrowRequest(request.id, status: .returned)
    }

    func canMarkReturned(_ request: BorrowRequest) -> Bool {
        guard appState.currentUser != nil else { return false }
        return request.status == .approved
    }
}
