//
//  AddItemViewModel.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation
import SwiftUI
import Combine
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class AddItemViewModel: ObservableObject {
    @Published var input = NewThreadItemInput()
    @Published var selectedUIImage: UIImage?
    @Published var selectedPhotoData: Data?
    @Published var imageErrorMessage: String?

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

    func loadSelectedPhoto(from item: PhotosPickerItem) async {
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                selectedPhotoData = data
                #if canImport(UIKit)
                selectedUIImage = UIImage(data: data)
                #endif
            }
        } catch {
            imageErrorMessage = "Could not load selected image."
        }
    }

    func save(in appState: AppState) -> ThreadItem? {
        guard canSave else { return nil }

        if let selectedPhotoData {
            do {
                input.imageName = try ThreadItemImageStore.saveImageData(selectedPhotoData)
            } catch {
                imageErrorMessage = error.localizedDescription
                return nil
            }
        }

        return appState.addThreadItem(input)
    }
}
