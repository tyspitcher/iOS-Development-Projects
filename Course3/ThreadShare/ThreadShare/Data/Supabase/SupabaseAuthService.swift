//
//  SupabaseAuthService.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

final class SupabaseAuthService {
    private let client: SupabaseHTTPClient

    init(client: SupabaseHTTPClient? = nil) {
        self.client = client ?? SupabaseHTTPClient(sessionProvider: nil)
    }

    func signUp(email: String, password: String) async throws -> SupabaseSession {
        let response: SupabaseAuthSessionResponse = try await client.request(
            path: "/auth/v1/signup",
            method: SupabaseHTTPClient.HTTPMethod.post,
            body: ["email": email, "password": password],
            useAuth: false
        )
        return makeSession(from: response)
    }

    func signIn(email: String, password: String) async throws -> SupabaseSession {
        let response: SupabaseAuthSessionResponse = try await client.request(
            path: "/auth/v1/token",
            method: .post,
            queryItems: [URLQueryItem(name: "grant_type", value: "password")],
            body: ["email": email, "password": password],
            useAuth: false
        )
        return makeSession(from: response)
    }

    func validateOrRefresh(_ session: SupabaseSession) async throws -> SupabaseSession {
        do {
            let _: SupabaseAuthUser = try await client.request(path: "/auth/v1/user", method: .get, useAuth: true)
            return session
        } catch {
            return try await refresh(session)
        }
    }

    func refresh(_ session: SupabaseSession) async throws -> SupabaseSession {
        let response: SupabaseAuthSessionResponse = try await client.request(
            path: "/auth/v1/token",
            method: .post,
            queryItems: [URLQueryItem(name: "grant_type", value: "refresh_token")],
            body: ["refresh_token": session.refreshToken],
            useAuth: false
        )
        return makeSession(from: response)
    }

    func signOut(_ session: SupabaseSession) async throws {
        try await client.requestVoid(path: "/auth/v1/logout", method: .post, useAuth: true)
    }

    func requestPasswordReset(email: String) async throws {
        struct RecoverRequest: Encodable {
            let email: String
        }

        try await client.requestVoid(
            path: "/auth/v1/recover",
            method: .post,
            queryItems: [URLQueryItem(name: "redirect_to", value: "threadshare://auth-callback")],
            body: try JSONEncoder.threadShareSupabase.encode(RecoverRequest(email: email)),
            useAuth: false
        )
    }

    func bootstrapProfile(profile: UserProfile, email: String, session: SupabaseSession) async throws {
        let row = SupabaseProfileRow(
            id: profile.id,
            email: email,
            display_name: profile.displayName,
            username: profile.username,
            bio: profile.bio,
            avatar_bucket: "avatars",
            avatar_path: profile.avatarImageName,
            city: profile.city,
            visibility: profile.visibility.rawValue,
            style_interests: profile.styleInterests,
            favorite_brands: profile.favoriteBrands,
            color_palette_preference_ids: profile.colorPalettePreferenceIDs,
            follower_count: profile.followerCount,
            following_count: profile.followingCount,
            created_at: Date(),
            updated_at: Date()
        )

        let bootstrapClient = SupabaseHTTPClient(sessionProvider: StaticSessionProvider(session: session))
        let data = try JSONEncoder.threadShareSupabase.encode(row)
        try await bootstrapClient.requestVoid(
            path: "/rest/v1/profiles",
            method: .post,
            queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
            body: data,
            useAuth: true
        )
    }

    private func makeSession(from response: SupabaseAuthSessionResponse) -> SupabaseSession {
        SupabaseSession(
            accessToken: response.access_token,
            refreshToken: response.refresh_token,
            expiresAt: response.expires_in.map { Date().addingTimeInterval(TimeInterval($0)) },
            userID: response.user.id,
            email: response.user.email ?? ""
        )
    }
}

private final class StaticSessionProvider: SupabaseSessionProviding {
    let session: SupabaseSession?

    init(session: SupabaseSession?) {
        self.session = session
    }
}
