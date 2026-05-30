//
//  SupabaseNotificationDispatchService.swift
//  ThreadShare
//
//  Created by Codex on 5/28/26.
//

import Foundation

final class SupabaseNotificationDispatchService {
    private let client: SupabaseHTTPClient

    init(sessionProvider: SupabaseSessionProviding) {
        self.client = SupabaseHTTPClient(sessionProvider: sessionProvider)
    }

    func dispatchPush(notificationID: UUID) async throws {
        let payload = DispatchPayload(notification_id: notificationID)
        let data = try JSONEncoder.threadShareSupabase.encode(payload)
        try await client.requestVoid(
            path: "/functions/v1/send-push-notification",
            method: .post,
            body: data,
            includePreferHeader: false
        )
    }
}

private struct DispatchPayload: Encodable {
    let notification_id: UUID
}
