//
//  SupabaseRealtimeSyncService.swift
//  ThreadShare
//
//  Created by Codex on 5/28/26.
//

import Foundation
import Combine
import Supabase

@MainActor
final class SupabaseRealtimeSyncService: ObservableObject {
    private struct PendingSynchronization {
        let session: SupabaseSession?
        let forceReconnect: Bool
    }

    private let client: SupabaseClient
    private let refreshHandler: @Sendable () async -> Void
    private var currentAccessToken: String?
    private var refreshTask: Task<Void, Never>?
    private var synchronizationInProgress = false
    private var pendingSynchronization: PendingSynchronization?
    private let liveTables = [
        "profiles",
        "thread_items",
        "likes",
        "item_comments",
        "borrow_requests",
        "messages",
        "notifications",
        "notification_preferences",
        "return_reminders",
        "follows",
        "friend_requests",
        "user_blocks"
    ]

    init(refreshHandler: @escaping @Sendable () async -> Void) {
        self.client = SupabaseClient(
            supabaseURL: SupabaseConfig.projectURL,
            supabaseKey: SupabaseConfig.publishableKey
        )
        self.refreshHandler = refreshHandler
    }

    func synchronize(session: SupabaseSession?, forceReconnect: Bool = false) async {
        if synchronizationInProgress {
            pendingSynchronization = PendingSynchronization(session: session, forceReconnect: forceReconnect)
            return
        }

        synchronizationInProgress = true
        defer {
            synchronizationInProgress = false
            if let pendingSynchronization {
                self.pendingSynchronization = nil
                Task {
                    await self.synchronize(
                        session: pendingSynchronization.session,
                        forceReconnect: pendingSynchronization.forceReconnect
                    )
                }
            }
        }

        guard let session else {
            await disconnect()
            return
        }

        guard forceReconnect || currentAccessToken != session.accessToken else {
            return
        }

        await disconnect()

        do {
            try await client.auth.setSession(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken
            )
        } catch {
            currentAccessToken = nil
            return
        }

        currentAccessToken = session.accessToken

        let channel = client.realtime.channel("threadshare-live")
        for table in liveTables {
            channel.on("postgres_changes", filter: ChannelFilter(event: "*", schema: "public", table: table)) { [weak self] _ in
                self?.scheduleRefresh()
            }
        }
        channel.subscribe()
    }

    func disconnect() async {
        refreshTask?.cancel()
        refreshTask = nil
        currentAccessToken = nil
        pendingSynchronization = nil
        await client.removeAllChannels()
    }

    private func scheduleRefresh() {
        refreshTask?.cancel()
        refreshTask = Task { [refreshHandler] in
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await refreshHandler()
        }
    }
}
