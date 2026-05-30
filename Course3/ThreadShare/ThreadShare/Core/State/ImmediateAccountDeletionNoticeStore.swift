//
//  ImmediateAccountDeletionNoticeStore.swift
//  ThreadShare
//
//  Created by Codex on 5/23/26.
//

import Foundation

final class ImmediateAccountDeletionNoticeStore {
    private let userDefaults: UserDefaults
    private let keyPrefix = "ThreadShare.immediateAccountDeletionNotice"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load(for userID: UUID?) -> ImmediateAccountDeletionNotice? {
        guard let userID else { return nil }
        guard
            let data = userDefaults.data(forKey: key(for: userID)),
            let notice = try? JSONDecoder.threadShareSupabase.decode(ImmediateAccountDeletionNotice.self, from: data)
        else {
            return nil
        }
        return notice
    }

    func save(_ notice: ImmediateAccountDeletionNotice) {
        guard let data = try? JSONEncoder.threadShareSupabase.encode(notice) else { return }
        userDefaults.set(data, forKey: key(for: notice.userID))
    }

    private func key(for userID: UUID) -> String {
        "\(keyPrefix).\(userID.uuidString)"
    }
}
