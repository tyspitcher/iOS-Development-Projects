//
//  AddItemViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation
import Combine
import SwiftUI
import ImageIO

@MainActor
final class AddItemViewModel: ObservableObject {
    @Published var input = NewThreadItemInput()
    @Published var selectedPhotoData: Data?
    @Published var imageErrorMessage: String?
    @Published var isSaving = false

    init() {
        input.size = ThreadItemSizeCatalog.defaultSize(for: input.category)
    }

    var canSave: Bool {
        !input.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !input.brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !input.size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !input.colorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var sizeOptions: [String] {
        ThreadItemSizeCatalog.options(for: input.category)
    }

    func updateCategory(_ category: ClothingCategory) {
        input.category = category
        if !ThreadItemSizeCatalog.options(for: category).contains(input.size) {
            input.size = ThreadItemSizeCatalog.defaultSize(for: category)
        }
    }

    func loadSelectedPhoto(from data: Data) {
        guard let aspectRatio = Self.aspectRatio(for: data) else {
            imageErrorMessage = "Could not read the selected image. Please try another photo."
            return
        }

        if let validationMessage = ThreadItemPhotoPolicy.validationMessage(for: aspectRatio) {
            selectedPhotoData = nil
            input.photoAspectRatio = ThreadItemPhotoPolicy.fallbackAspectRatio
            imageErrorMessage = validationMessage
            return
        }

        selectedPhotoData = data
        input.photoAspectRatio = aspectRatio
        imageErrorMessage = nil
    }

    func save(in appState: AppState) async -> ThreadItem? {
        guard canSave else { return nil }
        isSaving = true
        defer { isSaving = false }

        do {
            return try await appState.addThreadItem(input, imageData: selectedPhotoData)
        } catch {
            imageErrorMessage = error.localizedDescription
            return nil
        }
    }

    private static func aspectRatio(for data: Data) -> Double? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] else {
            return nil
        }
        guard
            let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
            let height = properties[kCGImagePropertyPixelHeight] as? CGFloat,
            width > 0
        else {
            return nil
        }
        return Double(height / width)
    }
}
