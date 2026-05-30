//
//  FashionPreferences.swift
//  ThreadShare
//
//  Created by Codex on 5/22/26.
//

import Foundation

struct FashionStyle: Identifiable, Codable, Hashable {
    typealias ID = String

    let id: ID
    let displayName: String
}

struct FashionStyleBrandMapping: Identifiable, Codable, Hashable {
    var id: FashionStyle.ID { styleID }

    let styleID: FashionStyle.ID
    let brandNames: [String]
}

struct FashionColorPalette: Identifiable, Codable, Hashable {
    typealias ID = String

    let id: ID
    let displayName: String
    let colorHexes: [String]
}

struct FashionPreferenceSelection: Codable, Hashable {
    var styleIDs: [FashionStyle.ID]
    var favoriteBrands: [String]
    var colorPaletteIDs: [FashionColorPalette.ID]

    init(
        styleIDs: [FashionStyle.ID] = [],
        favoriteBrands: [String] = [],
        colorPaletteIDs: [FashionColorPalette.ID] = []
    ) {
        self.styleIDs = FashionPreferenceCatalog.deduplicated(styleIDs)
        self.favoriteBrands = FashionPreferenceCatalog.normalizedBrandNames(from: favoriteBrands)
        self.colorPaletteIDs = FashionPreferenceCatalog.deduplicated(colorPaletteIDs)
    }

    var suggestedBrandNames: [String] {
        FashionPreferenceCatalog.suggestedBrandNames(forStyleIDs: styleIDs)
    }

    mutating func toggleStyle(_ styleID: FashionStyle.ID) {
        Self.toggle(styleID, in: &styleIDs)
    }

    mutating func toggleBrand(_ brandName: String) {
        let normalized = FashionPreferenceCatalog.normalizedBrandName(brandName)
        guard normalized.isEmpty == false else { return }
        Self.toggle(normalized, in: &favoriteBrands)
    }

    mutating func addCustomBrand(_ brandName: String) {
        let normalized = FashionPreferenceCatalog.normalizedBrandName(brandName)
        guard normalized.isEmpty == false else { return }
        if favoriteBrands.contains(normalized) == false {
            favoriteBrands.append(normalized)
        }
    }

    mutating func removeBrand(_ brandName: String) {
        favoriteBrands.removeAll { $0.caseInsensitiveCompare(brandName) == .orderedSame }
    }

    mutating func toggleColorPalette(_ paletteID: FashionColorPalette.ID) {
        Self.toggle(paletteID, in: &colorPaletteIDs)
    }

    private static func toggle(_ value: String, in values: inout [String]) {
        if let index = values.firstIndex(of: value) {
            values.remove(at: index)
        } else {
            values.append(value)
        }
    }
}

enum FashionPreferenceCatalog {
    enum StyleID {
        static let casualEveryday = "casual-everyday"
        static let preppy = "preppy"
        static let streetwear = "streetwear"
        static let bohemianBoho = "bohemian-boho"
        static let minimalist = "minimalist"
        static let classicTimeless = "classic-timeless"
        static let quietLuxury = "quiet-luxury"
        static let oldMoney = "old-money"
        static let vintage = "vintage"
        static let y2k = "y2k"
        static let punk = "punk"
        static let goth = "goth"
        static let emoScene = "emo-scene"
        static let grunge = "grunge"
        static let rockerBiker = "rocker-biker"
        static let countryWestern = "country-western"
        static let workwear = "workwear"
        static let militaryUtility = "military-utility"
        static let techwear = "techwear"
        static let gorpcore = "gorpcore"
        static let skater = "skater"
        static let sportyBlokecore = "sporty-blokecore"
        static let athleisure = "athleisure"
        static let businessFormal = "business-formal"
        static let businessCasual = "business-casual"
        static let luxuryHighFashion = "luxury-high-fashion"
        static let artsyAvantGarde = "artsy-avant-garde"
        static let eclecticMaximalist = "eclectic-maximalist"
        static let glamNightOut = "glam-night-out"
        static let festivalRave = "festival-rave"
        static let parisianChic = "parisian-chic"
        static let resortCoastal = "resort-coastal"
        static let cottagecore = "cottagecore"
        static let coquette = "coquette"
        static let romanticSoftFeminine = "romantic-soft-feminine"
        static let balletcore = "balletcore"
        static let darkAcademia = "dark-academia"
        static let lightAcademia = "light-academia"
        static let retroFuturism = "retro-futurism"
        static let kFashionJFashionInspired = "k-fashion-j-fashion-inspired"
        static let kawaiiHarajuku = "kawaii-harajuku"
        static let whimsigoth = "whimsigoth"
    }

    enum ColorPaletteID {
        static let softNeutrals = "soft-neutrals"
        static let warmEarth = "warm-earth"
        static let coolTones = "cool-tones"
        static let jewelTones = "jewel-tones"
        static let pastelRomance = "pastel-romance"
        static let monochrome = "monochrome"
        static let coastal = "coastal"
        static let highContrast = "high-contrast"
    }

    static let styles: [FashionStyle] = [
        FashionStyle(id: StyleID.casualEveryday, displayName: "Casual / Everyday"),
        FashionStyle(id: StyleID.preppy, displayName: "Preppy"),
        FashionStyle(id: StyleID.streetwear, displayName: "Streetwear"),
        FashionStyle(id: StyleID.bohemianBoho, displayName: "Bohemian / Boho"),
        FashionStyle(id: StyleID.minimalist, displayName: "Minimalist"),
        FashionStyle(id: StyleID.classicTimeless, displayName: "Classic / Timeless"),
        FashionStyle(id: StyleID.quietLuxury, displayName: "Quiet Luxury"),
        FashionStyle(id: StyleID.oldMoney, displayName: "Old Money"),
        FashionStyle(id: StyleID.vintage, displayName: "Vintage"),
        FashionStyle(id: StyleID.y2k, displayName: "Y2K"),
        FashionStyle(id: StyleID.punk, displayName: "Punk"),
        FashionStyle(id: StyleID.goth, displayName: "Goth"),
        FashionStyle(id: StyleID.emoScene, displayName: "Emo / Scene"),
        FashionStyle(id: StyleID.grunge, displayName: "Grunge"),
        FashionStyle(id: StyleID.rockerBiker, displayName: "Rocker / Biker"),
        FashionStyle(id: StyleID.countryWestern, displayName: "Country Western"),
        FashionStyle(id: StyleID.workwear, displayName: "Workwear"),
        FashionStyle(id: StyleID.militaryUtility, displayName: "Military / Utility"),
        FashionStyle(id: StyleID.techwear, displayName: "Techwear"),
        FashionStyle(id: StyleID.gorpcore, displayName: "Gorpcore"),
        FashionStyle(id: StyleID.skater, displayName: "Skater"),
        FashionStyle(id: StyleID.sportyBlokecore, displayName: "Sporty / Blokecore"),
        FashionStyle(id: StyleID.athleisure, displayName: "Athleisure"),
        FashionStyle(id: StyleID.businessFormal, displayName: "Business Formal"),
        FashionStyle(id: StyleID.businessCasual, displayName: "Business Casual"),
        FashionStyle(id: StyleID.luxuryHighFashion, displayName: "Luxury / High Fashion"),
        FashionStyle(id: StyleID.artsyAvantGarde, displayName: "Artsy / Avant-Garde"),
        FashionStyle(id: StyleID.eclecticMaximalist, displayName: "Eclectic / Maximalist"),
        FashionStyle(id: StyleID.glamNightOut, displayName: "Glam / Night Out"),
        FashionStyle(id: StyleID.festivalRave, displayName: "Festival / Rave"),
        FashionStyle(id: StyleID.parisianChic, displayName: "Parisian Chic"),
        FashionStyle(id: StyleID.resortCoastal, displayName: "Resort / Coastal"),
        FashionStyle(id: StyleID.cottagecore, displayName: "Cottagecore"),
        FashionStyle(id: StyleID.coquette, displayName: "Coquette"),
        FashionStyle(id: StyleID.romanticSoftFeminine, displayName: "Romantic / Soft Feminine"),
        FashionStyle(id: StyleID.balletcore, displayName: "Balletcore"),
        FashionStyle(id: StyleID.darkAcademia, displayName: "Dark Academia"),
        FashionStyle(id: StyleID.lightAcademia, displayName: "Light Academia"),
        FashionStyle(id: StyleID.retroFuturism, displayName: "Retro Futurism"),
        FashionStyle(id: StyleID.kFashionJFashionInspired, displayName: "K-Fashion / J-Fashion Inspired"),
        FashionStyle(id: StyleID.kawaiiHarajuku, displayName: "Kawaii / Harajuku"),
        FashionStyle(id: StyleID.whimsigoth, displayName: "Whimsigoth")
    ]

    static let brandMappings: [FashionStyleBrandMapping] = [
        FashionStyleBrandMapping(styleID: StyleID.casualEveryday, brandNames: ["Land's End", "Gap", "Madewell", "Levi's"]),
        FashionStyleBrandMapping(styleID: StyleID.preppy, brandNames: ["Ralph Lauren", "Lacoste", "J.Crew", "Tommy Hilfiger"]),
        FashionStyleBrandMapping(styleID: StyleID.streetwear, brandNames: ["Supreme", "Stussy", "A Bathing Ape / BAPE", "Off-White"]),
        FashionStyleBrandMapping(styleID: StyleID.bohemianBoho, brandNames: ["Free People", "Anthropologie", "Johnny Was", "Farm Rio"]),
        FashionStyleBrandMapping(styleID: StyleID.minimalist, brandNames: ["COS", "Uniqlo", "Everlane", "Muji"]),
        FashionStyleBrandMapping(styleID: StyleID.classicTimeless, brandNames: ["Brooks Brothers", "Ralph Lauren", "J.Crew", "Banana Republic"]),
        FashionStyleBrandMapping(styleID: StyleID.quietLuxury, brandNames: ["The Row", "Loro Piana", "Brunello Cucinelli", "Max Mara"]),
        FashionStyleBrandMapping(styleID: StyleID.oldMoney, brandNames: ["Ralph Lauren", "Brooks Brothers", "Loro Piana", "Hermes"]),
        FashionStyleBrandMapping(styleID: StyleID.vintage, brandNames: ["Levi's", "Lee", "Wrangler", "Carhartt"]),
        FashionStyleBrandMapping(styleID: StyleID.y2k, brandNames: ["Juicy Couture", "Baby Phat", "Von Dutch", "Diesel"]),
        FashionStyleBrandMapping(styleID: StyleID.punk, brandNames: ["Dr. Martens", "Vivienne Westwood", "Tripp NYC", "Underground England"]),
        FashionStyleBrandMapping(styleID: StyleID.goth, brandNames: ["Killstar", "Demonia", "Disturbia", "Dr. Martens"]),
        FashionStyleBrandMapping(styleID: StyleID.emoScene, brandNames: ["Hot Topic", "Vans", "Converse", "Tripp NYC"]),
        FashionStyleBrandMapping(styleID: StyleID.grunge, brandNames: ["Dr. Martens", "Converse", "Levi's", "Carhartt"]),
        FashionStyleBrandMapping(styleID: StyleID.rockerBiker, brandNames: ["Harley-Davidson", "AllSaints", "Schott NYC", "Dr. Martens"]),
        FashionStyleBrandMapping(styleID: StyleID.countryWestern, brandNames: ["Ariat", "Wrangler", "Cinch", "Lucchese"]),
        FashionStyleBrandMapping(styleID: StyleID.workwear, brandNames: ["Carhartt", "Dickies", "Red Wing", "Filson"]),
        FashionStyleBrandMapping(styleID: StyleID.militaryUtility, brandNames: ["Alpha Industries", "Rothco", "Carhartt WIP", "Dickies"]),
        FashionStyleBrandMapping(styleID: StyleID.techwear, brandNames: ["Acronym", "Nike ACG", "Stone Island Shadow Project", "Y-3"]),
        FashionStyleBrandMapping(styleID: StyleID.gorpcore, brandNames: ["Arc'teryx", "Salomon", "Patagonia", "The North Face"]),
        FashionStyleBrandMapping(styleID: StyleID.skater, brandNames: ["Vans", "Thrasher", "Dickies", "Santa Cruz"]),
        FashionStyleBrandMapping(styleID: StyleID.sportyBlokecore, brandNames: ["Adidas", "Nike", "Umbro", "Puma"]),
        FashionStyleBrandMapping(styleID: StyleID.athleisure, brandNames: ["Lululemon", "Alo Yoga", "Outdoor Voices", "Gymshark"]),
        FashionStyleBrandMapping(styleID: StyleID.businessFormal, brandNames: ["Hugo Boss", "Brooks Brothers", "Theory", "Calvin Klein"]),
        FashionStyleBrandMapping(styleID: StyleID.businessCasual, brandNames: ["Banana Republic", "J.Crew", "Theory", "Madewell"]),
        FashionStyleBrandMapping(styleID: StyleID.luxuryHighFashion, brandNames: ["Gucci", "Prada", "Louis Vuitton", "Chanel"]),
        FashionStyleBrandMapping(styleID: StyleID.artsyAvantGarde, brandNames: ["Comme des Garcons", "Issey Miyake", "Rick Owens", "Maison Margiela"]),
        FashionStyleBrandMapping(styleID: StyleID.eclecticMaximalist, brandNames: ["Farm Rio", "Desigual", "Gucci", "Anna Sui"]),
        FashionStyleBrandMapping(styleID: StyleID.glamNightOut, brandNames: ["House of CB", "Revolve", "Meshki", "Alexander Wang"]),
        FashionStyleBrandMapping(styleID: StyleID.festivalRave, brandNames: ["IHeartRaves", "Dolls Kill", "Freedom Rave Wear", "Club Exx"]),
        FashionStyleBrandMapping(styleID: StyleID.parisianChic, brandNames: ["Sezane", "Sandro", "Maje", "Ba&sh"]),
        FashionStyleBrandMapping(styleID: StyleID.resortCoastal, brandNames: ["Tory Burch", "Lilly Pulitzer", "Tommy Bahama", "Vilebrequin"]),
        FashionStyleBrandMapping(styleID: StyleID.cottagecore, brandNames: ["Loveshackfancy", "Free People", "Hill House Home", "Doen"]),
        FashionStyleBrandMapping(styleID: StyleID.coquette, brandNames: ["Loveshackfancy", "Sandy Liang", "For Love & Lemons", "Reformation"]),
        FashionStyleBrandMapping(styleID: StyleID.romanticSoftFeminine, brandNames: ["Loveshackfancy", "Sezane", "For Love & Lemons", "Anthropologie"]),
        FashionStyleBrandMapping(styleID: StyleID.balletcore, brandNames: ["Sandy Liang", "Repetto", "Alo Yoga", "Lululemon"]),
        FashionStyleBrandMapping(styleID: StyleID.darkAcademia, brandNames: ["Brooks Brothers", "Ralph Lauren", "J.Crew", "Doc Martens"]),
        FashionStyleBrandMapping(styleID: StyleID.lightAcademia, brandNames: ["J.Crew", "Ralph Lauren", "Sezane", "Madewell"]),
        FashionStyleBrandMapping(styleID: StyleID.retroFuturism, brandNames: ["Diesel", "Coperni", "Courreges", "Paco Rabanne"]),
        FashionStyleBrandMapping(styleID: StyleID.kFashionJFashionInspired, brandNames: ["ADER Error", "Gentle Monster", "Comme des Garcons PLAY", "WEGO"]),
        FashionStyleBrandMapping(styleID: StyleID.kawaiiHarajuku, brandNames: ["Sanrio", "WEGO", "Angelic Pretty", "6%DOKIDOKI"]),
        FashionStyleBrandMapping(styleID: StyleID.whimsigoth, brandNames: ["Disturbia", "Free People", "Killstar", "Anna Sui"])
    ]

    static let colorPalettes: [FashionColorPalette] = [
        FashionColorPalette(id: ColorPaletteID.softNeutrals, displayName: "Soft Neutrals", colorHexes: ["F6EFEA", "E8DDD3", "C9B8A8", "7A6A5F"]),
        FashionColorPalette(id: ColorPaletteID.warmEarth, displayName: "Warm Earth", colorHexes: ["7A4E2D", "A66A3F", "C79A5B", "49613A"]),
        FashionColorPalette(id: ColorPaletteID.coolTones, displayName: "Cool Tones", colorHexes: ["243B53", "486581", "7FA8AC", "D9E8E8"]),
        FashionColorPalette(id: ColorPaletteID.jewelTones, displayName: "Jewel Tones", colorHexes: ["144E4A", "4B145F", "8A1538", "C99700"]),
        FashionColorPalette(id: ColorPaletteID.pastelRomance, displayName: "Pastel Romance", colorHexes: ["F7C8D0", "EFD6F6", "C9D7F8", "FFF1B8"]),
        FashionColorPalette(id: ColorPaletteID.monochrome, displayName: "Monochrome", colorHexes: ["111111", "555555", "BDBDBD", "F7F7F7"]),
        FashionColorPalette(id: ColorPaletteID.coastal, displayName: "Coastal", colorHexes: ["F8F2E7", "BFD7EA", "5F8EA6", "1F4E5F"]),
        FashionColorPalette(id: ColorPaletteID.highContrast, displayName: "High Contrast", colorHexes: ["050505", "FFFFFF", "D72638", "F4C430"])
    ]

    private static let stylesByID = Dictionary(uniqueKeysWithValues: styles.map { ($0.id, $0) })
    private static let styleIDsByNormalizedLabel = Dictionary(
        uniqueKeysWithValues: styles.map { (normalize($0.displayName), $0.id) }
    )
    private static let brandNamesByStyleID = Dictionary(uniqueKeysWithValues: brandMappings.map { ($0.styleID, $0.brandNames) })
    private static let colorPalettesByID = Dictionary(uniqueKeysWithValues: colorPalettes.map { ($0.id, $0) })

    static func style(for id: FashionStyle.ID) -> FashionStyle? {
        stylesByID[id]
    }

    static func displayName(forStyleID id: FashionStyle.ID) -> String {
        stylesByID[id]?.displayName ?? id
    }

    static func displayNames(forStyleIDs ids: [FashionStyle.ID]) -> [String] {
        ids.map { displayName(forStyleID: $0) }
    }

    static func styleID(matching value: String) -> FashionStyle.ID? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if stylesByID[trimmed] != nil {
            return trimmed
        }
        return styleIDsByNormalizedLabel[normalize(trimmed)]
    }

    static func normalizedStyleIDs(from values: [String]) -> [FashionStyle.ID] {
        deduplicated(values.compactMap { styleID(matching: $0) ?? fallbackStyleID(forLegacyValue: $0) })
    }

    static func brandNames(forStyleID styleID: FashionStyle.ID) -> [String] {
        brandNamesByStyleID[styleID] ?? []
    }

    static func suggestedBrandNames(forStyleIDs styleIDs: [FashionStyle.ID]) -> [String] {
        deduplicated(styleIDs.flatMap { brandNames(forStyleID: $0) })
    }

    static func normalizedBrandName(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .joined(separator: " ")
    }

    static func normalizedBrandNames(from values: [String]) -> [String] {
        deduplicated(values.map { normalizedBrandName($0) }.filter { $0.isEmpty == false })
    }

    static func colorPalette(for id: FashionColorPalette.ID) -> FashionColorPalette? {
        colorPalettesByID[id]
    }

    static func displayName(forColorPaletteID id: FashionColorPalette.ID) -> String {
        colorPalettesByID[id]?.displayName ?? id
    }

    static func colorPaletteDisplayNames(for ids: [FashionColorPalette.ID]) -> [String] {
        ids.map { displayName(forColorPaletteID: $0) }
    }

    static func avatarColorHexes(forPaletteIDs ids: [FashionColorPalette.ID]) -> [String] {
        let hexes = ids.flatMap { paletteID in
            colorPalettesByID[paletteID]?.colorHexes ?? []
        }

        return deduplicated(hexes)
    }

    private static func fallbackStyleID(forLegacyValue value: String) -> FashionStyle.ID? {
        let normalized = normalize(value)
        if normalized.contains("capsule") || normalized.contains("campus") || normalized.contains("dinner") {
            return StyleID.casualEveryday
        }
        if normalized.contains("sport") || normalized.contains("set matching") {
            return StyleID.athleisure
        }
        if normalized.contains("street") || normalized.contains("hype") || normalized.contains("sneaker") {
            return StyleID.streetwear
        }
        if normalized.contains("glam") || normalized.contains("date night") || normalized.contains("formal") {
            return StyleID.glamNightOut
        }
        if normalized.contains("earth") || normalized.contains("utilitarian") {
            return StyleID.workwear
        }
        if normalized.contains("minimal") {
            return StyleID.minimalist
        }
        if normalized.contains("y2k") || normalized.contains("trend") {
            return StyleID.y2k
        }
        return nil
    }

    private static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "&", with: "and")
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .joined(separator: " ")
    }

    static func deduplicated(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.filter { seen.insert($0).inserted }
    }
}
