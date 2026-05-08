//
//  TakeMeToYourLeaderController.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/21/26.
//

import SwiftUI
import Foundation
import Observation

protocol RepresentativeAPIControllerProtocol {
    func fetchLeaderInfo(matching query: [String: String]) async throws -> [LeaderInfo]
}

extension RepresentativeAPIControllerProtocol where Self == TakeMeToYourLeaderController {
    static var live: TakeMeToYourLeaderController { TakeMeToYourLeaderController() }
}

class TakeMeToYourLeaderController: RepresentativeAPIControllerProtocol {
    enum LeaderInfoError: LocalizedError {
        case itemNotFound
    }
    func fetchLeaderInfo(matching query: [String: String]) async throws -> [LeaderInfo] {
        var urlComponents = URLComponents(string: "https://whoismyrepresentative.com/getall_mems.php")!
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LeaderInfoError.itemNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let leaderInfo = try jsonDecoder.decode(SearchResponse.self, from: data)
        return leaderInfo.results
    }
}
