//
//  DataBackedImageView.swift
//  ThreadShare
//
//  Created by Codex on 5/27/26.
//

import SwiftUI
import ImageIO

struct DataBackedImageView: View {
    let data: Data
    var contentMode: ContentMode = .fit

    var body: some View {
        Group {
            if let image = decodedImage {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            }
        }
    }

    private var decodedImage: Image? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}
