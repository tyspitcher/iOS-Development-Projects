//
//  ThreadItemImageSizing.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/6/26.
//

import SwiftUI
import ImageIO

enum ThreadItemImageSizing {
    private static var heightRatioCache: [String: CGFloat] = [:]
    private static let assetHeightRatios: [String: CGFloat] = [
        "adidasShoe": 2000.0 / 2000.0,
        "aloSocks": 1395.0 / 930.0,
        "anine": 985.0 / 849.0,
        "aritziaSkirt": 1000.0 / 687.0,
        "aritziaTrouser": 1158.0 / 847.0,
        "bag": 2000.0 / 2000.0,
        "birkenstock": 1312.0 / 1312.0,
        "carhartt": 1600.0 / 1600.0,
        "carharttPant": 500.0 / 500.0,
        "coachBag": 527.0 / 760.0,
        "goldEarrings": 906.0 / 814.0,
        "grayOvershirt": 1000.0 / 1000.0,
        "greenDress": 1500.0 / 1000.0,
        "jordans": 702.0 / 1094.0,
        "levis": 493.0 / 381.0,
        "luluHoodie": 1728.0 / 1440.0,
        "luluJacket": 1728.0 / 1440.0,
        "luluWindbreaker": 1728.0 / 1440.0,
        "madewellJacket": 445.0 / 250.0,
        "motoJacket": 1384.0 / 1075.0,
        "ohPollyHalter": 1260.0 / 840.0,
        "patagonia": 1200.0 / 1600.0,
        "patagonia2": 1346.0 / 1346.0,
        "pinkDress": 1280.0 / 1280.0,
        "pinkSet": 1395.0 / 930.0,
        "platforms": 808.0 / 808.0,
        "scarff": 1250.0 / 1000.0,
        "whiteSneakers": 762.0 / 930.0
    ]

    /// Returns image height/width ratio. Prefers actual asset dimensions, with model fallback.
    static func heightRatio(for item: ThreadItem) -> CGFloat {
        if let cached = heightRatioCache[item.imageName] {
            return cached
        }

        let fallback = max(CGFloat(item.photoAspectRatio), 0.5)

        if let localURL = ThreadItemImageStore.localImageURL(for: item.imageName),
           let source = CGImageSourceCreateWithURL(localURL as CFURL, nil),
           let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
           let height = properties[kCGImagePropertyPixelHeight] as? CGFloat,
           width > 0 {
            let ratio = max(height / width, 0.5)
            heightRatioCache[item.imageName] = ratio
            return ratio
        }

        if let assetRatio = assetHeightRatios[item.imageName] {
            let ratio = max(assetRatio, 0.5)
            heightRatioCache[item.imageName] = ratio
            return ratio
        }

        heightRatioCache[item.imageName] = fallback
        return fallback
    }
}
