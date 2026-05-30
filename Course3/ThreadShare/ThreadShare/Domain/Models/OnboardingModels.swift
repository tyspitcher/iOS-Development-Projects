//
//  OnboardingModels.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum OnboardingUsageGoal: String, CaseIterable, Codable, Identifiable {
    case wardrobeInspo
    case fashionTrends
    case closetSharing
    case borrowTracking
    case easyShopping

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wardrobeInspo: "Wardrobe Inspo"
        case .fashionTrends: "Fashion Trends"
        case .closetSharing: "Closet Sharing"
        case .borrowTracking: "Borrow Tracking"
        case .easyShopping: "Easy Shopping"
        }
    }
}

struct OnboardingQuestionnaireDraft: Codable, Hashable {
    var userID: UUID
    var email: String
    var preferredStyleIDs: [FashionStyle.ID]
    var favoriteBrands: [String]
    var preferredColorPaletteIDs: [FashionColorPalette.ID]
    var usageGoals: [OnboardingUsageGoal]

    init(
        userID: UUID,
        email: String,
        preferredStyleIDs: [FashionStyle.ID] = [],
        favoriteBrands: [String] = [],
        preferredColorPaletteIDs: [FashionColorPalette.ID] = [],
        usageGoals: [OnboardingUsageGoal] = []
    ) {
        self.userID = userID
        self.email = email
        self.preferredStyleIDs = preferredStyleIDs
        self.favoriteBrands = favoriteBrands
        self.preferredColorPaletteIDs = preferredColorPaletteIDs
        self.usageGoals = usageGoals
    }
}

extension OnboardingQuestionnaireDraft {
    var fashionPreferenceSelection: FashionPreferenceSelection {
        FashionPreferenceSelection(
            styleIDs: preferredStyleIDs,
            favoriteBrands: favoriteBrands,
            colorPaletteIDs: preferredColorPaletteIDs
        )
    }

    var preferredStyleDisplayNames: [String] {
        FashionPreferenceCatalog.displayNames(forStyleIDs: preferredStyleIDs)
    }

    var preferredColorPaletteDisplayNames: [String] {
        FashionPreferenceCatalog.colorPaletteDisplayNames(for: preferredColorPaletteIDs)
    }

    var suggestedBrandNamesFromStyles: [String] {
        FashionPreferenceCatalog.suggestedBrandNames(forStyleIDs: preferredStyleIDs)
    }
}
