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
    @StateObject private var viewModel = AddItemViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?

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

                    if let selectedUIImage = viewModel.selectedUIImage {
                        Image(uiImage: selectedUIImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                Section("Details") {
                    TextField("Item", text: $viewModel.input.title)
                    TextField("Brand", text: $viewModel.input.brand)
                    Picker("Size", selection: $viewModel.input.size) {
                        ForEach(viewModel.sizeOptions, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(.menu)
                    TextField("Color", text: $viewModel.input.colorName)
                }

                Section("Type") {
                    Picker(
                        "Category",
                        selection: Binding(
                            get: { viewModel.input.category },
                            set: { viewModel.updateCategory($0) }
                        )
                    ) {
                        ForEach(ClothingCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Occasion", selection: $viewModel.input.occasion) {
                        ForEach(OccasionCategory.allCases) { occasion in
                            Text(occasion.displayName).tag(occasion)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Condition", selection: $viewModel.input.condition) {
                        ForEach(ItemCondition.allCases) { condition in
                            Text(condition.displayName).tag(condition)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Extra") {
                    TextField("Notes", text: $viewModel.input.notes, axis: .vertical)
                    TextField("Fits Like", text: $viewModel.input.fitsLike)
                    TextField("Where Purchased", text: $viewModel.input.wherePurchased)
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
                        guard viewModel.canSave else { return }
                        _ = viewModel.save(in: appState)
                        if viewModel.imageErrorMessage == nil {
                            dismiss()
                        }
                    }
                    .font(AppTheme.bodyFont(size: 16))
                    .disabled(!viewModel.canSave)
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    await viewModel.loadSelectedPhoto(from: newItem)
                }
            }
            .alert("Photo Error", isPresented: Binding(
                get: { viewModel.imageErrorMessage != nil },
                set: { if !$0 { viewModel.imageErrorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.imageErrorMessage ?? "")
            }
        }
    }
}
