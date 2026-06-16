//
//  SupabaseHTTPClient.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum SupabaseHTTPClientError: Error {
    case invalidURL
    case invalidResponse
    case badStatusCode(Int, Data)
}

extension SupabaseHTTPClientError {
    var responseMessage: String? {
        guard case let .badStatusCode(_, data) = self else { return nil }
        return String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var responseCode: String? {
        guard case let .badStatusCode(_, data) = self else { return nil }
        return (try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data))?.code
    }
}

extension SupabaseHTTPClientError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The Supabase request URL was invalid."
        case .invalidResponse:
            return "Supabase returned an invalid response."
        case let .badStatusCode(statusCode, _):
            if let responseMessage, responseMessage.isEmpty == false {
                return "Supabase returned \(statusCode): \(responseMessage)"
            }
            return "Supabase returned \(statusCode)."
        }
    }
}

private struct SupabaseErrorResponse: Decodable {
    let code: String?
}

final class SupabaseHTTPClient {
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case patch = "PATCH"
        case put = "PUT"
        case delete = "DELETE"
    }

    private let baseURL: URL
    private let session: URLSession
    private let sessionProvider: SupabaseSessionProviding?
    private let decoder = JSONDecoder.threadShareSupabase
    private let encoder = JSONEncoder.threadShareSupabase

    init(
        baseURL: URL = SupabaseConfig.projectURL,
        session: URLSession = .shared,
        sessionProvider: SupabaseSessionProviding? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.sessionProvider = sessionProvider
    }

    func request<Response: Decodable>(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        useAuth: Bool = true
    ) async throws -> Response {
        let data = try await requestData(path: path, method: method, queryItems: queryItems, body: nil, useAuth: useAuth)
        return try decoder.decode(Response.self, from: data)
    }

    func request<Response: Decodable, Body: Encodable>(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        body: Body,
        useAuth: Bool = true
    ) async throws -> Response {
        let data = try encoder.encode(body)
        let responseData = try await requestData(path: path, method: method, queryItems: queryItems, body: data, useAuth: useAuth)
        return try decoder.decode(Response.self, from: responseData)
    }

    func requestVoid(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        useAuth: Bool = true,
        includePreferHeader: Bool = true,
        additionalHeaders: [String: String] = [:]
    ) async throws {
        _ = try await requestData(
            path: path,
            method: method,
            queryItems: queryItems,
            body: body,
            useAuth: useAuth,
            includePreferHeader: includePreferHeader,
            additionalHeaders: additionalHeaders
        )
    }

    private func requestData(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem],
        body: Data?,
        useAuth: Bool,
        includePreferHeader: Bool = true,
        additionalHeaders: [String: String] = [:]
    ) async throws -> Data {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw SupabaseHTTPClientError.invalidURL
        }
        components.path = baseURL.path + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems
        guard let url = components.url else { throw SupabaseHTTPClientError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        var headers = SupabaseConfig.publicHeaders
        if body != nil && includePreferHeader {
            headers["Prefer"] = "return=representation"
        }
        if useAuth, let accessToken = sessionProvider?.session?.accessToken {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        additionalHeaders.forEach { headers[$0] = $1 }
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseHTTPClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw SupabaseHTTPClientError.badStatusCode(httpResponse.statusCode, data)
        }

        return data
    }
}
