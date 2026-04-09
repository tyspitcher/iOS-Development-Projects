//
//  Emoji.swift
//  EmojiDictionary
//
//  Created by Jane Madsen on 10/30/25.
//

import Foundation

struct Emoji: Equatable, Codable, Identifiable {
    var id: UUID = UUID()
    var symbol: String
    var name: String
    var description: String
    var usage: String
    private static let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("emojis").appendingPathExtension("plist")
    
//    static func sampleEmojis() -> [Emoji] {
//        return [
//            Emoji(symbol: "😀", name: "Grinning Face", description: "A typical smiley face.", usage: "happiness"),
//            Emoji(symbol: "💩", name: "Pile of Poo", description: "A smiling pile of poo.", usage: "disappointment"),
//            Emoji(symbol: "🦧", name: "Orangutan", description: "An orangutan sitting", usage: "random humor")
//            ]
//    }
    
    static func saveToFile(emojis: [Emoji]) {
        let encoder = PropertyListEncoder()
        let encodedEmoji = try? encoder.encode(emojis)
        try? encodedEmoji?.write(to: archiveURL)
    }
    static func loadFromFile() -> [Emoji] {
        let decoder = PropertyListDecoder()
        if let data = try? Data(contentsOf: archiveURL),
           let decoded = try? decoder.decode([Emoji].self, from: data) {
            return decoded
        } else {
            return []
        }
    }
}

