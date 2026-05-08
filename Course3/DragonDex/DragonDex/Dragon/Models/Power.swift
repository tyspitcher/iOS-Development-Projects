//
//  Power.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/5/25.
//
import Foundation

struct Power: Hashable, Identifiable {
    let id = UUID()
    let name: String
    let energyCost: String
    let description: String
}

extension Power {
    static let gargothPowers: [Power] = [
        Power(name: "FireBreath", energyCost: "2", description: "All close enemies take 2 damage"),
        Power(name: "Claw Swip", energyCost: "3", description: "Closest enemy takes 4 damage"),
        Power(name: "Hard Scales", energyCost: "2", description: "All attacks against Gargon do -1 damage for the round")
    ]
    static let nurgekPowers: [Power] = [
        Power(name: "Acid Spit", energyCost: "4", description: "One enemy up to medium range takes 2 damage at the beginning of each round for 3 rounds"),
        Power(name: "Claw Swip", energyCost: "3", description: "Closest enemy takes 4 damage"),
        Power(name: "Acidic Aura/Burning Eyes", energyCost: "2", description: "enemies at close range do -1 damage on all attacks")
    ]
    static let shriekPowers: [Power] = [
        Power(name: "Dark Breath Bolt", energyCost: "3", description: "One enemy up to long range takes 4 damage"),
        Power(name: "Ambush", energyCost: "NA", description: "Must be Shrouded. End Shroud to deal one enemy at close range 6 damage"),
        Power(name: "Shroud", energyCost: "5", description: "Until ambush is used, can only be targeted at close range")
    ]
}


