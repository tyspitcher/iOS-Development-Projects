//
//  OnboardingModels.swift
//  ThreadShare
//
//  Created by Codex on 5/13/26.
//

import Foundation

enum OnboardingStylePreference: String, CaseIterable, Codable, Identifiable {
    case quietLuxury
    case sportPreppy
    case streetwear
    case romantic
    case classicMinimal
    case eclecticVintage

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .quietLuxury: "Quiet Luxury"
        case .sportPreppy: "Sport / Preppy"
        case .streetwear: "Streetwear"
        case .romantic: "Romantic"
        case .classicMinimal: "Classic / Minimal"
        case .eclecticVintage: "Eclectic / Vintage"
        }
    }
}

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
    var preferredStyles: [OnboardingStylePreference]
    var favoriteBrands: [String]
    var usageGoals: [OnboardingUsageGoal]

    init(
        userID: UUID,
        email: String,
        preferredStyles: [OnboardingStylePreference] = [],
        favoriteBrands: [String] = [],
        usageGoals: [OnboardingUsageGoal] = []
    ) {
        self.userID = userID
        self.email = email
        self.preferredStyles = preferredStyles
        self.favoriteBrands = favoriteBrands
        self.usageGoals = usageGoals
    }
}
