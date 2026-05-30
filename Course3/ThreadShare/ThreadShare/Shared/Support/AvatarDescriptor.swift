//
//  AvatarDescriptor.swift
//  ThreadShare
//
//  Created by Codex on 5/23/26.
//

import SwiftUI

enum AvatarDescriptor {
    private static let generatedPrefix = "generated:"
    private static let delimiter: Character = "|"
    private static let defaultFallbackColors = [
        "7FA8AC",
        "DFB9A6",
        "C99982",
        "BFD7EA",
        "7A6A5F",
        "C9B8A8",
        "8FB8BA",
        "EFDCD3"
    ]

    static func generated(initials: String, colorHex: String) -> String {
        "\(generatedPrefix)\(sanitizeInitials(initials))\(delimiter)\(sanitizeHex(colorHex))"
    }

    static func parseGenerated(_ value: String) -> GeneratedAvatar? {
        guard value.hasPrefix(generatedPrefix) else { return nil }

        let payload = String(value.dropFirst(generatedPrefix.count))
        let parts = payload.split(separator: delimiter, maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }

        let initials = sanitizeInitials(String(parts[0]))
        let colorHex = sanitizeHex(String(parts[1]))
        guard initials.isEmpty == false, colorHex.isEmpty == false else { return nil }

        return GeneratedAvatar(initials: initials, colorHex: colorHex)
    }

    static func initials(for displayName: String, username: String) -> String {
        let displayComponents = displayName
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .filter { $0.isEmpty == false }

        if displayComponents.count >= 2 {
            let first = String(displayComponents[0].prefix(1))
            let second = String(displayComponents[1].prefix(1))
            return sanitizeInitials(first + second)
        }

        if let firstWord = displayComponents.first, firstWord.count >= 2 {
            return sanitizeInitials(String(firstWord.prefix(2)))
        }

        let usernameComponents = username
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .filter { $0.isEmpty == false }

        if usernameComponents.count >= 2 {
            let first = String(usernameComponents[0].prefix(1))
            let second = String(usernameComponents[1].prefix(1))
            return sanitizeInitials(first + second)
        }

        if let firstWord = usernameComponents.first, firstWord.isEmpty == false {
            return sanitizeInitials(String(firstWord.prefix(2)))
        }

        return "TS"
    }

    static func fallbackColorHexes(for paletteIDs: [FashionColorPalette.ID]) -> [String] {
        let paletteColors = FashionPreferenceCatalog.avatarColorHexes(forPaletteIDs: paletteIDs)
        let colors = paletteColors.isEmpty ? defaultFallbackColors : paletteColors
        return deduplicated(colors)
    }

    static func preferredFallbackColorHex(
        for paletteIDs: [FashionColorPalette.ID],
        seed: String
    ) -> String {
        let colors = fallbackColorHexes(for: paletteIDs)
        guard colors.isEmpty == false else {
            return defaultFallbackColors[0]
        }

        let hash = seed.unicodeScalars.reduce(into: 0) { result, scalar in
            result = result &* 31 &+ Int(scalar.value)
        }

        let index = Int(hash.magnitude % UInt(colors.count))
        return colors[index]
    }

    static func contrastColor(for hex: String) -> Color {
        luminance(for: hex) > 0.58 ? AppTheme.ink : Color.white
    }

    private static func sanitizeInitials(_ value: String) -> String {
        let filtered = value
            .uppercased()
            .filter { $0.isLetter || $0.isNumber }
        return String(filtered.prefix(2))
    }

    private static func sanitizeHex(_ value: String) -> String {
        let cleaned = value.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).uppercased()
        if cleaned.count >= 6 {
            return String(cleaned.prefix(6))
        }

        return defaultFallbackColors[0]
    }

    private static func luminance(for hex: String) -> Double {
        let cleaned = sanitizeHex(hex)
        guard let value = UInt32(cleaned, radix: 16) else { return 0.5 }
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0

        func adjust(_ component: Double) -> Double {
            component <= 0.03928 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * adjust(red) + 0.7152 * adjust(green) + 0.0722 * adjust(blue)
    }

    private static func deduplicated(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0.uppercased()).inserted }
    }
}

struct GeneratedAvatar: Hashable {
    let initials: String
    let colorHex: String
}

extension Color {
    init(threadShareHex: String) {
        let cleaned = threadShareHex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
