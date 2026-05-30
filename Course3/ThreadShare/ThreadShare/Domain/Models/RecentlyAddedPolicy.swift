//
//  RecentlyAddedPolicy.swift
//  ThreadShare
//
//  Created by Codex on 5/27/26.
//

import Foundation

enum RecentlyAddedPolicy {
    static let displayWindowDays = 10

    static func isRecentlyAdded(createdAt: Date, now: Date = Date()) -> Bool {
        guard let cutoff = Calendar.current.date(
            byAdding: .day,
            value: -displayWindowDays,
            to: now
        ) else {
            return false
        }

        return createdAt >= cutoff
    }
}

extension ThreadItem {
    var isRecentlyAdded: Bool {
        RecentlyAddedPolicy.isRecentlyAdded(createdAt: createdAt)
    }
}
