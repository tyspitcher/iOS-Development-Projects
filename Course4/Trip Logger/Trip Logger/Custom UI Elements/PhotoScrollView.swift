//
//  PhotoScrollView.swift
//  Trip Logger
//
//  Created by Jane Madsen on 4/29/25.
//


import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct PhotoScrollView: View {
    var journalEntry: JournalEntry
    
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImage: Image? = nil
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(journalEntry.photos) { photo in
                if let uiImage = UIImage(data: photo.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                // Photo Picker appears at end of list of photos
                PhotosPicker(
                    selection: $selectedItems,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: 20) {
                        Image(systemName: "plus.rectangle.on.rectangle")
                            .resizable()
                            .scaledToFit()
                        
                        Text("Add Photos...")
                    }
                }
                .frame(width: 150, height: 150)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                .onChange(of: selectedItems) {
                    loadTransferable()
                }
            }
        }
        .padding()
    }
    
    // Pulls the image data for each selected photo
    func loadTransferable() {
        for item in selectedItems {
            item.loadTransferable(type: Data.self) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let data = data {
                            let newPhoto = Photo(data: data)
                            journalEntry.photos.append(newPhoto)
                        }
                    case .failure(let error):
                        print("Failed to load image: \(error)")
                    }
                }
            }
        }
    }
}
