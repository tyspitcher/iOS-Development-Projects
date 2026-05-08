//
//  LeaderInfo.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/22/26.
//

import Foundation
import SwiftUI

struct SearchResponse: Codable {
    let results: [LeaderInfo]
}
struct LeaderInfo: Identifiable, Codable {
    var id = UUID()
    var name: String
    var phone: String
    var office: String
    var website: String
    
    enum CodingKeys: String, CodingKey {
        case name, phone, office
        case website = "link"
    }
}
