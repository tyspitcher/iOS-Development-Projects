//
//  AppTheme.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

enum AppTheme {
    static let background = Color(hex: "F6EFEA")
    static let surface = Color.white
    static let elevatedSurface = Color(hex: "FFF9F5")
    static let ink = Color(red: 0.13, green: 0.12, blue: 0.11)
    static let mutedInk = Color(red: 0.47, green: 0.43, blue: 0.39)
    static let softInk = Color(red: 0.68, green: 0.63, blue: 0.58)
    static let accent = Color(hex: "7FA8AC")
    static let accentSoft = Color(hex: "DFB9A6").opacity(0.35)
    static let moss = Color(hex: "7FA8AC")
    static let clay = Color(hex: "DFB9A6")
    static let butter = Color(red: 0.94, green: 0.76, blue: 0.35)
    static let border = Color.black.opacity(0.07)

    static let cornerRadius: CGFloat = 18
    static let smallCornerRadius: CGFloat = 12
    static let contentSpacing: CGFloat = 16
    static let pagePadding: CGFloat = 20
    static let softShadow = Color.black.opacity(0.08)

    static func titleFont(size: CGFloat) -> Font {
        .custom("PlayfairDisplay-Regular", size: size)
    }

    static func brandFont(size: CGFloat) -> Font {
        .custom("PlayfairDisplay-Regular", size: size)
    }

    static func bodyFont(size: CGFloat) -> Font {
        .custom("Inter-Regular", size: size)
    }

    static func color(for category: ClothingCategory) -> Color {
        switch category {
        case .tops: accent
        case .bottoms: Color(red: 0.24, green: 0.39, blue: 0.58)
        case .dresses: Color(red: 0.52, green: 0.32, blue: 0.58)
        case .shoes: moss
        case .sweaters: clay
        case .accessories: butter
        }
    }
}

private extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
