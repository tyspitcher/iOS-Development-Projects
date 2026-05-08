//
//  ItemCellView.swift
//  iTunesSearch
//
//  Created by Jane Madsen on 11/3/25.
//

import SwiftUI

struct ItemCellView: View {
    let item: StoreItem
    let onPlayButtonPressed: () -> Void
    init(item: StoreItem, onPlayButtonPressed: @escaping () -> Void) {
        self.item = item
        self.onPlayButtonPressed = onPlayButtonPressed
    }

    var body: some View {
        HStack {
            if let artworkURL = item.albumArtURL {
                AsyncImage(url: artworkURL) { media in
                    if let image = media.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 65, height: 65)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 65)
                    .foregroundColor(.gray)
            }
            VStack(alignment: .leading) {
                Text(item.name ?? "")
                    .font(.headline)
                Text(item.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if item.previewURL != nil {
                Button {
                    onPlayButtonPressed()
                } label: {
                    Image(systemName: "play.circle")
                        .font(.title2)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
