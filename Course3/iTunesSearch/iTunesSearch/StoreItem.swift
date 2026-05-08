//
//  StoreItem.swift
//  iTunesSearch
//
//  Created by Tyson Pitcher on 4/16/26.
//
import Foundation
import Observation

struct SearchResponse: Codable {
    let results: [StoreItem]
}

struct StoreItem: Codable, Hashable, Identifiable {
    let id = UUID()
    let artistName: String
    let album: String?
    let albumArtURL: URL?
    let previewURL: URL?
    var name: String? { album }
    var artist: String { artistName }
    
    enum CodingKeys: String, CodingKey {
        case artistName
        case album = "collectionName"
        case albumArtURL = "artworkUrl100"
        case previewURL = "previewUrl"
    }
}
