//
//  AppTheme.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI

enum AppTheme {
    static let background = Color.dynamic(light: Color(hex: "F5EEE6"), dark: Color(hex: "111722"))
    static let secondaryBackground = Color.dynamic(light: Color(hex: "E9E0D7"), dark: Color(hex: "18212E"))
    static let surface = Color.dynamic(light: Color(hex: "FFFCFA"), dark: Color(hex: "202A39"))
    static let elevatedSurface = Color.dynamic(light: Color(hex: "FAF4EE"), dark: Color(hex: "263142"))
    static let ink = Color.dynamic(light: Color(hex: "1E2430"), dark: Color(hex: "F3EDE7"))
    static let mutedInk = Color.dynamic(light: Color(hex: "645E59"), dark: Color(hex: "B8B0A8"))
    static let softInk = Color.dynamic(light: Color(hex: "8C857E"), dark: Color(hex: "8D97A3"))
    static let accent = Color.dynamic(light: Color(hex: "334A69"), dark: Color(hex: "90A7C4"))
    static let accentPressed = Color.dynamic(light: Color(hex: "22354C"), dark: Color(hex: "778DA8"))
    static let accentSoft = Color.dynamic(light: Color(hex: "DCE4EF"), dark: Color(hex: "243140"))
    static let moss = Color.dynamic(light: Color(hex: "D2A961"), dark: Color(hex: "C79B57"))
    static let clay = Color.dynamic(light: Color(hex: "C9775E"), dark: Color(hex: "BA6D57"))
    static let warmAccentFill = Color.dynamic(light: Color(hex: "EAD9CA"), dark: Color(hex: "382C27"))
    static let warmAccentHighlight = Color.dynamic(light: Color(hex: "D8A55B"), dark: Color(hex: "D0A064"))
    static let butter = Color.dynamic(light: Color(hex: "D8B25A"), dark: Color(hex: "D1A45B"))
    static let border = Color.dynamic(light: Color(hex: "000000").opacity(0.08), dark: Color(hex: "334052"))
    static let strongBorder = Color.dynamic(light: Color(hex: "000000").opacity(0.18), dark: Color(hex: "465568"))
    static let pillBackground = Color.dynamic(light: Color(hex: "FFFFFF"), dark: Color(hex: "1C2533"))
    static let pillBorder = Color.dynamic(light: Color(hex: "000000").opacity(0.10), dark: Color(hex: "334154"))
    static let selectedPillBackground = Color.dynamic(light: Color(hex: "334A69"), dark: Color(hex: "2A415D"))
    static let selectedPillText = Color.dynamic(light: Color(hex: "FFFCFA"), dark: Color(hex: "F3EDE7"))

    static let cornerRadius: CGFloat = 25
    static let smallCornerRadius: CGFloat = 19
    static let pagePadding: CGFloat = 22
    static let sectionSpacing: CGFloat = 20
    static let cardPadding: CGFloat = 18
    static let cardSpacing: CGFloat = 16
    static let contentSpacing: CGFloat = 14
    static let compactSpacing: CGFloat = 10
    static let tightSpacing: CGFloat = 10
    static let xSmallSpacing: CGFloat = 8
    static let microSpacing: CGFloat = 6
    static let buttonHeight: CGFloat = 50
    static let pillHeight: CGFloat = 40
    static let chipHeight: CGFloat = 32
    static let badgeHeight: CGFloat = 28
    static let softShadow = Color.dynamic(light: Color.black.opacity(0.08), dark: Color.black.opacity(0.32))

    static func titleFont(size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }

    static func brandFont(size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }

    static func bodyFont(size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    static func bodyFont(size: CGFloat, weight: Font.Weight) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func captionFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func color(for category: ClothingCategory) -> Color {
        switch category {
        case .tops: accent
        case .bottoms: Color.dynamic(light: Color(hex: "627894"), dark: Color(hex: "8DA0BB"))
        case .dresses: clay
        case .shoes: moss
        case .sweaters: Color.dynamic(light: Color(hex: "8C7868"), dark: Color(hex: "A08D7E"))
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
