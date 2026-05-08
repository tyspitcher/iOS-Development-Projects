//
//  ThreadItemImageSizing.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum ThreadItemImageSizing {
    private static var heightRatioCache: [String: CGFloat] = [:]

    /// Returns image height/width ratio. Prefers actual asset dimensions, with model fallback.
    static func heightRatio(for item: ThreadItem) -> CGFloat {
        if let cached = heightRatioCache[item.imageName] {
            return cached
        }

        let fallback = max(CGFloat(item.photoAspectRatio), 0.5)

        #if canImport(UIKit)
        if
            let image = ThreadItemImageStore.uiImage(named: item.imageName),
            image.size.width > 0,
            image.size.height > 0
        {
            let ratio = image.size.height / image.size.width
            heightRatioCache[item.imageName] = max(ratio, 0.5)
            return max(ratio, 0.5)
        }
        #endif

        heightRatioCache[item.imageName] = fallback
        return fallback
    }
}
