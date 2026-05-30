//
//  SupabasePushNotificationService.swift
//  ThreadShare
//
//  Created by Codex on 5/27/26.
//

import Foundation

final class SupabasePushNotificationService {
    private let client: SupabaseHTTPClient
    private let session: SupabaseSession

    init(session: SupabaseSession) {
        self.session = session
        self.client = SupabaseHTTPClient(sessionProvider: StaticPushSessionProvider(session: session))
    }

    func registerDeviceToken(_ token: String, platform: String = "ios") async throws {
        let now = Date()
        let row = SupabasePushDeviceTokenRow(
            id: UUID(),
            user_id: session.userID,
            platform: platform,
            token: token,
            enabled: true,
            created_at: now,
            updated_at: now,
            last_registered_at: now
        )
        let data = try JSONEncoder.threadShareSupabase.encode(row)
        try await client.requestVoid(
            path: "/rest/v1/push_device_tokens",
            method: .post,
            queryItems: [URLQueryItem(name: "on_conflict", value: "token")],
            body: data
        )
    }
}

private final class StaticPushSessionProvider: SupabaseSessionProviding {
    let session: SupabaseSession?

    init(session: SupabaseSession) {
        self.session = session
    }
}
