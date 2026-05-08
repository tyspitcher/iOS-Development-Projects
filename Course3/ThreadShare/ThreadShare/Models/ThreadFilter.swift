//
//  ThreadFilter.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import Foundation

struct ThreadFilter: Codable, Equatable {
    var availableNowOnly = false
    var colorName: String?
    var size: String?
    var category: ClothingCategory?
    var occasion: OccasionCategory?
    var brand: String?
    var relationship: UserRelationship?

    var isEmpty: Bool {
        !availableNowOnly &&
        colorName == nil &&
        size == nil &&
        category == nil &&
        occasion == nil &&
        brand == nil &&
        relationship == nil
    }
}
