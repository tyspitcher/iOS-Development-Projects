//
//  RenderThreadRepository.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/5/26.
//

import Foundation

enum RenderThreadRepositoryError: Error {
    case invalidResponse
    case badStatusCode(Int)
}

final class RenderThreadRepository: ThreadRepository {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        baseURL: URL = ThreadShareEnvironment.backendBaseURL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    // Expected API shape (can be adjusted once backend contract is confirmed):
    // GET    /api/current-user
    // GET    /api/users
    // GET    /api/thread-items
    // GET    /api/borrow-requests
    // GET    /api/messages
    // GET    /api/friend-request-state
    // PUT    /api/users/{id}
    // PUT    /api/thread-items/{id}
    // PUT    /api/borrow-requests/{id}
    // PUT    /api/messages/{id}
    // PUT    /api/friend-request-state
    // DELETE /api/thread-items/{id}
    func fetchCurrentUser() async throws -> UserProfile {
        try await request(path: "/api/current-user", method: "GET")
    }

    func fetchUsers() async throws -> [UserProfile] {
        try await request(path: "/api/users", method: "GET")
    }

    func fetchThreadItems() async throws -> [ThreadItem] {
        try await request(path: "/api/thread-items", method: "GET")
    }

    func fetchBorrowRequests() async throws -> [BorrowRequest] {
        try await request(path: "/api/borrow-requests", method: "GET")
    }

    func fetchMessages() async throws -> [DMMessage] {
        try await request(path: "/api/messages", method: "GET")
    }

    func fetchFriendRequestState() async throws -> FriendRequestState {
        try await request(path: "/api/friend-request-state", method: "GET")
    }

    func saveUser(_ user: UserProfile) async throws {
        _ = try await request(path: "/api/users/\(user.id.uuidString)", method: "PUT", body: user) as UserProfile
    }

    func saveThreadItem(_ item: ThreadItem) async throws {
        _ = try await request(path: "/api/thread-items/\(item.id.uuidString)", method: "PUT", body: item) as ThreadItem
    }

    func saveBorrowRequest(_ borrowRequest: BorrowRequest) async throws {
        _ = try await request(
            path: "/api/borrow-requests/\(borrowRequest.id.uuidString)",
            method: "PUT",
            body: borrowRequest
        ) as BorrowRequest
    }

    func saveMessage(_ message: DMMessage) async throws {
        _ = try await request(path: "/api/messages/\(message.id.uuidString)", method: "PUT", body: message) as DMMessage
    }

    func saveFriendRequestState(_ state: FriendRequestState) async throws {
        _ = try await request(path: "/api/friend-request-state", method: "PUT", body: state) as FriendRequestState
    }

    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws {
        try await requestWithoutBody(path: "/api/thread-items/\(itemID.uuidString)", method: "DELETE")
    }

    private func request<Response: Decodable>(path: String, method: String) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        return try decodeResponse(data: data, response: response)
    }

    private func request<Body: Encodable, Response: Decodable>(
        path: String,
        method: String,
        body: Body
    ) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = method
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        return try decodeResponse(data: data, response: response)
    }

    private func decodeResponse<Response: Decodable>(data: Data, response: URLResponse) throws -> Response {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RenderThreadRepositoryError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw RenderThreadRepositoryError.badStatusCode(httpResponse.statusCode)
        }

        return try decoder.decode(Response.self, from: data)
    }

    private func requestWithoutBody(path: String, method: String) async throws {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RenderThreadRepositoryError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw RenderThreadRepositoryError.badStatusCode(httpResponse.statusCode)
        }
    }
}

final class RemoteFirstThreadRepository: ThreadRepository {
    private let primary: ThreadRepository
    private let fallback: ThreadRepository

    init(primary: ThreadRepository, fallback: ThreadRepository) {
        self.primary = primary
        self.fallback = fallback
    }

    func fetchCurrentUser() async throws -> UserProfile {
        do { return try await primary.fetchCurrentUser() }
        catch { return try await fallback.fetchCurrentUser() }
    }

    func fetchUsers() async throws -> [UserProfile] {
        do { return try await primary.fetchUsers() }
        catch { return try await fallback.fetchUsers() }
    }

    func fetchThreadItems() async throws -> [ThreadItem] {
        do { return try await primary.fetchThreadItems() }
        catch { return try await fallback.fetchThreadItems() }
    }

    func fetchBorrowRequests() async throws -> [BorrowRequest] {
        do { return try await primary.fetchBorrowRequests() }
        catch { return try await fallback.fetchBorrowRequests() }
    }

    func fetchMessages() async throws -> [DMMessage] {
        do { return try await primary.fetchMessages() }
        catch { return try await fallback.fetchMessages() }
    }

    func fetchFriendRequestState() async throws -> FriendRequestState {
        do { return try await primary.fetchFriendRequestState() }
        catch { return try await fallback.fetchFriendRequestState() }
    }

    // Writes are best-effort on primary; fallback keeps demo state consistent.
    func saveUser(_ user: UserProfile) async throws {
        do { try await primary.saveUser(user) }
        catch { try await fallback.saveUser(user) }
    }

    func saveThreadItem(_ item: ThreadItem) async throws {
        do { try await primary.saveThreadItem(item) }
        catch { try await fallback.saveThreadItem(item) }
    }

    func saveBorrowRequest(_ request: BorrowRequest) async throws {
        do { try await primary.saveBorrowRequest(request) }
        catch { try await fallback.saveBorrowRequest(request) }
    }

    func saveMessage(_ message: DMMessage) async throws {
        do { try await primary.saveMessage(message) }
        catch { try await fallback.saveMessage(message) }
    }

    func saveFriendRequestState(_ state: FriendRequestState) async throws {
        do { try await primary.saveFriendRequestState(state) }
        catch { try await fallback.saveFriendRequestState(state) }
    }

    func deleteThreadItem(_ itemID: ThreadItem.ID) async throws {
        do { try await primary.deleteThreadItem(itemID) }
        catch { try await fallback.deleteThreadItem(itemID) }
    }
}
