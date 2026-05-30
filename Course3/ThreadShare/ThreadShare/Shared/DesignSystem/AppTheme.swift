//
//  AppTheme.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

enum AppTheme {
    static let background = Color.dynamic(light: Color(hex: "F6EFEA"), dark: Color(hex: "171412"))
    static let secondaryBackground = Color.dynamic(light: Color(hex: "EEE4DE"), dark: Color(hex: "211D1A"))
    static let surface = Color.dynamic(light: Color.white, dark: Color(hex: "2A2521"))
    static let elevatedSurface = Color.dynamic(light: Color(hex: "FFF9F5"), dark: Color(hex: "332D28"))
    static let ink = Color.dynamic(light: Color(red: 0.13, green: 0.12, blue: 0.11), dark: Color(hex: "F4EEE8"))
    static let mutedInk = Color.dynamic(light: Color(red: 0.47, green: 0.43, blue: 0.39), dark: Color(hex: "C9BFB6"))
    static let softInk = Color.dynamic(light: Color(red: 0.68, green: 0.63, blue: 0.58), dark: Color(hex: "8F8580"))
    static let accent = Color.dynamic(light: Color(hex: "7FA8AC"), dark: Color(hex: "8FB8BA"))
    static let accentPressed = Color.dynamic(light: Color(hex: "5E8A8D"), dark: Color(hex: "6F9EA0"))
    static let accentSoft = Color.dynamic(light: Color(hex: "DFB9A6").opacity(0.35), dark: Color(hex: "263B3C"))
    static let moss = Color.dynamic(light: Color(hex: "7FA8AC"), dark: Color(hex: "8FB8BA"))
    static let clay = Color.dynamic(light: Color(hex: "DFB9A6"), dark: Color(hex: "D8BFB3"))
    static let warmAccentFill = Color.dynamic(light: Color(hex: "EFDCD3"), dark: Color(hex: "3B302B"))
    static let warmAccentHighlight = Color.dynamic(light: Color(hex: "C99982"), dark: Color(hex: "BFA99C"))
    static let butter = Color(red: 0.94, green: 0.76, blue: 0.35)
    static let border = Color.dynamic(light: Color.black.opacity(0.07), dark: Color(hex: "3A332E"))
    static let strongBorder = Color.dynamic(light: Color.black.opacity(0.16), dark: Color(hex: "514740"))
    static let pillBackground = Color.dynamic(light: Color.white, dark: Color(hex: "26211E"))
    static let pillBorder = Color.dynamic(light: Color.black.opacity(0.1), dark: Color(hex: "3C342F"))
    static let selectedPillBackground = Color.dynamic(light: Color(hex: "1A1A1A"), dark: Color(hex: "2C3F40"))
    static let selectedPillText = Color.dynamic(light: Color.white, dark: Color(hex: "F4EEE8"))

    static let cornerRadius: CGFloat = 18
    static let smallCornerRadius: CGFloat = 12
    static let contentSpacing: CGFloat = 16
    static let pagePadding: CGFloat = 20
    static let softShadow = Color.dynamic(light: Color.black.opacity(0.08), dark: Color.black.opacity(0.32))

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

    static func dynamic(light: Color, dark: Color) -> Color {
        #if canImport(UIKit)
        Color(
            UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(dark)
                    : UIColor(light)
            }
        )
        #else
        light
        #endif
    }
}
