//
//  SupabaseAuthService.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum SupabaseAccountCreationError: LocalizedError {
    case emailAlreadyRegistered
    case usernameAlreadyExists

    var errorDescription: String? {
        switch self {
        case .emailAlreadyRegistered:
            return "This email already has an account. Sign in with the password from your first attempt, or contact support if you cannot sign in."
        case .usernameAlreadyExists:
            return "That username is already taken. Please choose another one."
        }
    }
}

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
            requires_follower_approval: profile.requiresFollowerApproval,
            follower_count: profile.followerCount,
            following_count: profile.followingCount,
            created_at: Date(),
            updated_at: Date()
        )

        let bootstrapClient = SupabaseHTTPClient(sessionProvider: StaticSessionProvider(session: session))
        let data = try JSONEncoder.threadShareSupabase.encode(row)
        do {
            try await bootstrapClient.requestVoid(
                path: "/rest/v1/profiles",
                method: .post,
                queryItems: [URLQueryItem(name: "on_conflict", value: "id")],
                body: data,
                useAuth: true,
                additionalHeaders: ["Prefer": "resolution=merge-duplicates,return=representation"]
            )
        } catch {
            if isUsernameConflict(error) {
                throw SupabaseAccountCreationError.usernameAlreadyExists
            }
            if isEmailConflict(error) {
                throw SupabaseAccountCreationError.emailAlreadyRegistered
            }
            throw error
        }
    }

    func profileExists(userID: UUID, session: SupabaseSession) async throws -> Bool {
        struct ProfileIDRow: Decodable {
            let id: UUID
        }

        let bootstrapClient = SupabaseHTTPClient(sessionProvider: StaticSessionProvider(session: session))
        let rows: [ProfileIDRow] = try await bootstrapClient.request(
            path: "/rest/v1/profiles",
            method: .get,
            queryItems: [
                URLQueryItem(name: "id", value: "eq.\(userID.uuidString.lowercased())"),
                URLQueryItem(name: "select", value: "id"),
                URLQueryItem(name: "limit", value: "1")
            ],
            useAuth: true
        )
        return rows.isEmpty == false
    }

    func isAlreadyRegistered(_ error: Error) -> Bool {
        if let clientError = error as? SupabaseHTTPClientError {
            switch clientError.responseCode?.lowercased() {
            case "user_already_exists", "email_exists":
                return true
            default:
                break
            }
        }

        let message = backendMessage(for: error)
        return message.localizedCaseInsensitiveContains("user_already_exists")
            || message.localizedCaseInsensitiveContains("user already exists")
            || message.localizedCaseInsensitiveContains("user already registered")
            || message.localizedCaseInsensitiveContains("email already registered")
            || message.localizedCaseInsensitiveContains("email_exists")
    }

    private func isUsernameConflict(_ error: Error) -> Bool {
        let message = backendMessage(for: error)
        return message.localizedCaseInsensitiveContains("profiles_username_key")
            || (
                message.localizedCaseInsensitiveContains("duplicate key")
                && message.localizedCaseInsensitiveContains("username")
            )
    }

    private func isEmailConflict(_ error: Error) -> Bool {
        let message = backendMessage(for: error)
        return message.localizedCaseInsensitiveContains("profiles_email_key")
            || (
                message.localizedCaseInsensitiveContains("duplicate key")
                && message.localizedCaseInsensitiveContains("email")
            )
    }

    private func backendMessage(for error: Error) -> String {
        if let clientError = error as? SupabaseHTTPClientError,
           let responseMessage = clientError.responseMessage
        {
            return responseMessage
        }
        return (error as NSError).localizedDescription
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
