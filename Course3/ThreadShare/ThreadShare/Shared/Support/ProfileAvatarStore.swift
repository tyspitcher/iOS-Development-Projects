//
//  ProfileAvatarStore.swift
//  ThreadShare
//
//  Created by Codex on 5/23/26.
//

import Foundation

enum ProfileAvatarStore {
    static func saveLocalAvatarImageData(_ data: Data, userID: UUID) throws -> String {
        let directory = try avatarsDirectory()
        let fileName = "avatar-\(userID.uuidString)-\(Int(Date().timeIntervalSince1970)).jpg"
        let fileURL = directory.appendingPathComponent(fileName, isDirectory: false)
        try data.write(to: fileURL, options: [.atomic])
        return fileName
    }

    static func localAvatarURL(for imageName: String) -> URL? {
        guard imageName.isEmpty == false else { return nil }

        let directURL = URL(fileURLWithPath: imageName)
        if FileManager.default.fileExists(atPath: directURL.path) {
            return directURL
        }

        guard let directory = try? avatarsDirectory() else { return nil }
        let fileURL = directory.appendingPathComponent(imageName, isDirectory: false)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return fileURL
    }

    static func publicAvatarURL(for path: String) -> URL? {
        guard path.isEmpty == false else { return nil }
        return URL(string: "\(SupabaseConfig.projectURL.absoluteString)/storage/v1/object/public/avatars/\(path)")
    }

    private static func avatarsDirectory() throws -> URL {
        let baseDirectory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let avatarsDirectory = baseDirectory.appendingPathComponent("ThreadShare/avatars", isDirectory: true)
        if FileManager.default.fileExists(atPath: avatarsDirectory.path) == false {
            try FileManager.default.createDirectory(
                at: avatarsDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        return avatarsDirectory
    }
}
