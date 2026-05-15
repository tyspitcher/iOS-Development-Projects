//
//  ThreadItemSizeCatalog.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum ThreadItemSizeCatalog {
    static func options(for category: ClothingCategory) -> [String] {
        switch category {
        case .tops, .sweaters, .dresses:
            return [
                "XXS", "XS", "S", "M", "L", "XL", "XXL",
                "1X", "2X", "3X", "4X"
            ]
        case .bottoms:
            return [
                "00", "0", "2", "4", "6", "8", "10", "12", "14", "16",
                "18", "20", "22", "24", "26", "28", "30", "32",
                "23", "24", "25", "26", "27", "28", "29", "30", "31",
                "32", "33", "34", "36", "38", "40", "42", "44", "46",
                "48", "50", "1X", "2X", "3X", "4X"
            ]
        case .shoes:
            return [
                "5", "5.5", "6", "6.5", "7", "7.5", "8", "8.5", "9", "9.5",
                "10", "10.5", "11", "11.5", "12", "12.5", "13", "14", "15"
            ]
        case .accessories:
            return [
                "One Size", "Adjustable", "Small", "Medium", "Large"
            ]
        }
    }

    static func defaultSize(for category: ClothingCategory) -> String {
        options(for: category).first ?? "One Size"
    }
}
