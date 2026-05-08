//
//  Dragon.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/5/25.
//
import Foundation

struct Dragon: Hashable, Identifiable {
    static func == (lhs: Dragon, rhs: Dragon) -> Bool {
        lhs.name == rhs.name
    }
    
    let id = UUID()
    let name: String
    let picture: String
    let rating: String
    let health: String
    let powers: [Power]
}

extension Dragon {
    static var dragons: [Dragon] = [
        Dragon(name: "Gargoth", picture: "GargothPic", rating: "5", health: "15", powers: Power.gargothPowers),
        Dragon(name: "Nurgek", picture: "NurgekPic", rating: "6", health: "13", powers: Power.nurgekPowers),
        Dragon(name: "Shriek", picture: "ShriekPic", rating: "6", health: "12", powers: Power.shriekPowers)
    ]
}
