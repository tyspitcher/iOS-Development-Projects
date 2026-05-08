//
//  AddItemSheetView.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

struct AddItemSheetView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var input = NewThreadItemInput()
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var selectedUIImage: UIImage?
    @State private var imageErrorMessage: String?

    private var canSave: Bool {
        !input.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !input.brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !input.size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !input.colorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Choose Item Photo", systemImage: "photo.on.rectangle.angled")
                            .font(AppTheme.bodyFont(size: 16))
                    }

                    if let selectedUIImage {
                        Image(uiImage: selectedUIImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                Section("Details") {
                    TextField("Item", text: $input.title)
                    TextField("Brand", text: $input.brand)
                    TextField("Size", text: $input.size)
                    TextField("Color", text: $input.colorName)
                }

                Section("Type") {
                    Picker("Category", selection: $input.category) {
                        ForEach(ClothingCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    Picker("Occasion", selection: $input.occasion) {
                        ForEach(OccasionCategory.allCases) { occasion in
                            Text(occasion.displayName).tag(occasion)
                        }
                    }
                    Picker("Condition", selection: $input.condition) {
                        ForEach(ItemCondition.allCases) { condition in
                            Text(condition.displayName).tag(condition)
                        }
                    }
                }

                Section("Extra") {
                    TextField("Notes", text: $input.notes, axis: .vertical)
                    TextField("Fits Like", text: $input.fitsLike)
                    TextField("Where Purchased", text: $input.wherePurchased)
                }
            }
            .font(AppTheme.bodyFont(size: 16))
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(AppTheme.bodyFont(size: 16))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard canSave else { return }
                        if let selectedPhotoData {
                            do {
                                input.imageName = try ThreadItemImageStore.saveImageData(selectedPhotoData)
                            } catch {
                                imageErrorMessage = error.localizedDescription
                                return
                            }
                        }
                        _ = appState.addThreadItem(input)
                        dismiss()
                    }
                    .font(AppTheme.bodyFont(size: 16))
                    .disabled(!canSave)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self) {
                            selectedPhotoData = data
                            #if canImport(UIKit)
                            selectedUIImage = UIImage(data: data)
                            #endif
                        }
                    } catch {
                        imageErrorMessage = "Could not load selected image."
                    }
                }
            }
            .alert("Photo Error", isPresented: Binding(
                get: { imageErrorMessage != nil },
                set: { if !$0 { imageErrorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(imageErrorMessage ?? "")
            }
        }
    }
}
