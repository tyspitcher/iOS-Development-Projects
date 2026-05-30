//
//  ThreadItemPhotoPolicy.swift
//  ThreadShare
//
//  Created by Codex on 5/27/26.
//

import Foundation

enum ThreadItemPhotoPolicy {
    static let fallbackAspectRatio = 1.25
    static let minimumAspectRatio = 0.6
    static let maximumAspectRatio = 2.4

    static func normalizedAspectRatio(_ ratio: Double) -> Double {
        min(max(ratio, minimumAspectRatio), maximumAspectRatio)
    }

    static func validationMessage(for ratio: Double) -> String? {
        if ratio < minimumAspectRatio {
            return "This photo is very wide. Please crop it a little taller before adding it to your closet."
        }

        if ratio > maximumAspectRatio {
            return "This photo is very tall. Please crop it a little shorter before adding it to your closet."
        }

        return nil
    }
}
