//
//  NobelPrizeWinner.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/23/26.
//

import Foundation

struct NobelSearchResponse: Codable {
    let results: [NobelPrizeWinner]
}

struct NobelPrizeWinner: Codable, Identifiable {
    var id = UUID()
    var firstName: String
    var surName: String
    var motivation: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "firstname"
        case surName = "surname"
        case motivation
    }
}
