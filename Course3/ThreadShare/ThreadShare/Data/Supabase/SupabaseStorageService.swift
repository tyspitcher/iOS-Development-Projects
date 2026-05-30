//
//  SupabaseStorageService.swift
//  ThreadShare
//
//  Created by Codex on 5/23/26.
//

import Foundation

final class SupabaseStorageService {
    private let client: SupabaseHTTPClient

    init(sessionProvider: SupabaseSessionProviding) {
        self.client = SupabaseHTTPClient(sessionProvider: sessionProvider)
    }

    func uploadAvatarImage(
        _ imageData: Data,
        contentType: String,
        userID: UUID
    ) async throws -> String {
        let path = "\(userID.uuidString.lowercased())/avatar.jpg"
        try await client.requestVoid(
            path: "/storage/v1/object/avatars/\(path)",
            method: .post,
            body: imageData,
            useAuth: true,
            includePreferHeader: false,
            additionalHeaders: [
                "Content-Type": contentType,
                "x-upsert": "true"
            ]
        )
        return path
    }

    func uploadThreadItemImage(
        _ imageData: Data,
        contentType: String = "image/jpeg",
        ownerID: UUID,
        itemID: UUID
    ) async throws -> String {
        let path = "\(ownerID.uuidString.lowercased())/\(itemID.uuidString.lowercased()).jpg"
        try await client.requestVoid(
            path: "/storage/v1/object/item-images/\(path)",
            method: .post,
            body: imageData,
            useAuth: true,
            includePreferHeader: false,
            additionalHeaders: [
                "Content-Type": contentType,
                "x-upsert": "true"
            ]
        )
        return path
    }

    func deleteAvatarImage(at path: String) async throws {
        guard path.isEmpty == false else { return }
        try await client.requestVoid(
            path: "/storage/v1/object/avatars/\(path)",
            method: .delete,
            useAuth: true,
            includePreferHeader: false
        )
    }

    func deleteThreadItemImage(at path: String) async throws {
        guard path.isEmpty == false else { return }
        try await client.requestVoid(
            path: "/storage/v1/object/item-images/\(path)",
            method: .delete,
            useAuth: true,
            includePreferHeader: false
        )
    }

    func publicAvatarURL(for path: String) -> URL? {
        guard path.isEmpty == false else { return nil }
        return URL(string: "\(SupabaseConfig.projectURL.absoluteString)/storage/v1/object/public/avatars/\(path)")
    }
}
