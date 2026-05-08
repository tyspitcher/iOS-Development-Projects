//
//  NobelPrizeController.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/23/26.
//

import Foundation
import SwiftUI

// http://api.nobelprize.org/v1/prize.json
// query param: year
// returns: category -> id, firstname, surname, motivation, share

protocol NobelPrizeWinnerAPIControllerProtocol {
    func fetchNobelPrizeWinner(matching query: [String: String]) async throws -> [NobelPrizeWinner]
}

class NobelPrizeController {
    enum NobelPrizeWinnerError: LocalizedError {
        case itemNotFound
    }
    
    func fetchNobelWinner(matching query: [String: String]) async throws -> [NobelPrizeWinner] {
        var urlComponents = URLComponents(string: "http://api.nobelprize.org/v1/prize.json")!
        urlComponents.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value)}
        
        let (data, response) = try await URLSession.shared.data(from: urlComponents.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NobelPrizeWinnerError.itemNotFound
        }
        
        let jsonDecoder = JSONDecoder()
        let nobelPrizeWinner = try jsonDecoder.decode(NobelSearchResponse.self, from: data)
        return nobelPrizeWinner.results
    }
}
