//
//  ItemPhotoSourcePicker.swift
//  ThreadShare
//
//  Created by Codex on 5/22/26.
//

import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

struct ItemPhotoSourcePicker: View {
    let previewImageData: Data?
    let onLibraryImageData: (Data) -> Void
    let onCameraImageData: (Data) -> Void
    let onError: (String) -> Void

    @State private var isShowingSourceChooser = false
    @State private var isShowingCameraPicker = false
    @State private var isShowingPhotoLibraryPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingCameraUnavailableAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                isShowingSourceChooser = true
            } label: {
                Label(previewImageData == nil ? "Choose Item Photo" : "Change Item Photo", systemImage: "camera.viewfinder")
                    .font(AppTheme.bodyFont(size: 16))
                    .foregroundStyle(AppTheme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let previewImageData {
                DataBackedImageView(data: previewImageData, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
            }

            Text("Take a new photo or choose one from your library.")
                .font(AppTheme.bodyFont(size: 12))
                .foregroundStyle(AppTheme.mutedInk)
        }
        .confirmationDialog("Choose Photo Source", isPresented: $isShowingSourceChooser, titleVisibility: .visible) {
            cameraSourceButton
            Button("Photo Library") {
                isShowingPhotoLibraryPicker = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("ThreadShare can use the camera or your photo library for item photos.")
        }
        .photosPicker(
            isPresented: $isShowingPhotoLibraryPicker,
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self) {
                        onLibraryImageData(data)
                    } else {
                        onError("Could not load selected image.")
                    }
                } catch {
                    onError("Could not load selected image.")
                }
                await MainActor.run {
                    selectedPhotoItem = nil
                }
            }
        }
        .sheet(isPresented: $isShowingCameraPicker) {
            CameraImagePicker(isPresented: $isShowingCameraPicker) { data in
                onCameraImageData(data)
            }
            .ignoresSafeArea()
        }
        .alert("Camera Unavailable", isPresented: $isShowingCameraUnavailableAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device does not support camera capture right now. Photo Library is still available.")
        }
    }

    @ViewBuilder
    private var cameraSourceButton: some View {
        if cameraAvailable {
            Button("Camera") {
                isShowingCameraPicker = true
            }
        } else {
            Button("Camera") {
                isShowingCameraUnavailableAlert = true
            }
        }
    }

    private var cameraAvailable: Bool {
        #if canImport(UIKit)
        UIImagePickerController.isSourceTypeAvailable(.camera)
        #else
        false
        #endif
    }
}
