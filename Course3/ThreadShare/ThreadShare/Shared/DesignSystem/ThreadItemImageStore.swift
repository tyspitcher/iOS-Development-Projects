//
//  ThreadItemImageStore.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import Foundation

enum ThreadItemImageStore {
    static let localPrefix = "local://"
    private static let folderName = "threadshare-item-images"

    static func makeLocalImageName(fileName: String) -> String {
        localPrefix + fileName
    }

    static func localFileName(from imageName: String) -> String? {
        guard imageName.hasPrefix(localPrefix) else { return nil }
        return String(imageName.dropFirst(localPrefix.count))
    }

    static func saveImageData(_ data: Data) throws -> String {
        let ext = fileExtension(for: data)
        let fileName = "\(UUID().uuidString).\(ext)"
        let fileURL = try localFileURL(fileName: fileName)
        try data.write(to: fileURL, options: .atomic)
        return makeLocalImageName(fileName: fileName)
    }

    static func deleteImage(named imageName: String) throws {
        guard let localFileName = localFileName(from: imageName) else { return }
        let fileURL = try localFileURL(fileName: localFileName)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
    }

    static func publicItemImageURL(for imageName: String) -> URL? {
        guard imageName.isEmpty == false else { return nil }
        guard imageName.hasPrefix(localPrefix) == false else { return nil }
        guard imageName.contains("/") else { return nil }
        return URL(string: "\(SupabaseConfig.projectURL.absoluteString)/storage/v1/object/public/item-images/\(imageName)")
    }

    static func localImageURL(for imageName: String) -> URL? {
        guard let localFileName = localFileName(from: imageName) else { return nil }
        return try? localFileURL(fileName: localFileName)
    }

    static func imageURL(for imageName: String) -> URL? {
        if let localURL = localImageURL(for: imageName) {
            return localURL
        }
        return publicItemImageURL(for: imageName)
    }

    private static func localFileURL(fileName: String) throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let documents else { throw ImageStoreError.documentsDirectoryMissing }
        let folder = documents.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: folder.path) {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder.appendingPathComponent(fileName)
    }

    private static func fileExtension(for data: Data) -> String {
        if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) { return "png" }
        if data.starts(with: [0xFF, 0xD8, 0xFF]) { return "jpg" }
        if data.starts(with: [0x52, 0x49, 0x46, 0x46]) { return "webp" }
        return "jpg"
    }
}

enum ImageStoreError: LocalizedError {
    case documentsDirectoryMissing

    var errorDescription: String? {
        switch self {
        case .documentsDirectoryMissing:
            return "Could not access local document storage."
        }
    }
}
