//
//  SupabaseUserActivityService.swift
//  ThreadShare
//
//  Created by Codex on 5/27/26.
//

import Foundation

final class SupabaseUserActivityService {
    private let client: SupabaseHTTPClient
    private let session: SupabaseSession

    init(session: SupabaseSession) {
        self.session = session
        self.client = SupabaseHTTPClient(sessionProvider: StaticActivitySessionProvider(session: session))
    }

    func markLogin(at date: Date = Date()) async throws {
        try await patchActivity(
            LoginActivityPatch(
                last_login_at: date,
                last_active_at: date,
                updated_at: date
            )
        )
    }

    func markActive(at date: Date = Date()) async throws {
        try await patchActivity(
            ActiveActivityPatch(
                last_active_at: date,
                updated_at: date
            )
        )
    }

    private func patchActivity<Patch: Encodable>(_ patch: Patch) async throws {
        let data = try JSONEncoder.threadShareSupabase.encode(patch)
        try await client.requestVoid(
            path: "/rest/v1/profiles",
            method: .patch,
            queryItems: [URLQueryItem(name: "id", value: "eq.\(session.userID.uuidString)")],
            body: data,
            includePreferHeader: false
        )
    }
}

private struct LoginActivityPatch: Encodable {
    let last_login_at: Date
    let last_active_at: Date
    let updated_at: Date
}

private struct ActiveActivityPatch: Encodable {
    let last_active_at: Date
    let updated_at: Date
}

private final class StaticActivitySessionProvider: SupabaseSessionProviding {
    let session: SupabaseSession?

    init(session: SupabaseSession) {
        self.session = session
    }
}
