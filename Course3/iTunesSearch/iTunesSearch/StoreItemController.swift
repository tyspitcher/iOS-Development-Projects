//
//  StoreItemController.swift
//  iTunesSearch
//
//  Created by Tyson Pitcher on 4/16/26.
//

import Foundation
import Observation

@Observable
@MainActor
class StoreItemController {
    // func fetchPreview will build the URL for a preview
    func fetchPreview(from url: URL) async throws -> Data {
        enum ErrorCoding: String, LocalizedError {
            case error = "Unable to retrieve data."
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ErrorCoding.error
        }
        
        return data
    }
    
    
    // func fetchItems builds the URL with query info that is put into func parameters
    func fetchItems(matching query: [String: String]) async throws -> [StoreItem] {
        // this is the API used to retrieving the data from the service
        var components = URLComponents(string: "https://itunes.apple.com/search")!
        // query components are mapped into key and value pair
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

        enum ErrorCoding: String, LocalizedError {
            case error = "Unable to retrieve data."
        }
        
//        print(components.url!)
        
        // performing network request to iTunes Search, making sure it gets valid response
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ErrorCoding.error
        }
        
        // decoding JSON into SearchResponse and returning [StoreItem]
        let jsonDecoder = JSONDecoder()
        let responseObject = try jsonDecoder.decode(SearchResponse.self, from: data)
        return responseObject.results
    }
}
