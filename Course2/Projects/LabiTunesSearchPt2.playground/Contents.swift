
import SwiftUI
import Foundation
//              *****    iTunes Search (Part 2)    *****

// makes JSON look better in the console
extension Data {
    func prettyPrintedJSONString() {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyJSONString = String(data: jsonData, encoding: .utf8) else {
            print ("Failed to read JSON Object.")
            return
        }
        print(prettyJSONString)
    }
}

struct SearchResponse: Codable {
    let results: [StoreItem]
}

struct StoreItem: Codable {
    let artistName: String
    let album: String
    let albumArtURL: URL
    
    enum CodingKeys: String, CodingKey {
        case artistName
        case album = "collectionName"
        case albumArtURL = "artworkUrl100"
    }
}

// func fetchItems builds the URL with query info that is put into func parameters
func fetchItems(matching query: [String: String]) async throws -> [StoreItem] {
    // this is the API that we are using to retrieving the data from ⬇️
    var components = URLComponents(string: "https://itunes.apple.com/search")!
    // query components are mapped into key and value pair
    components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }

    enum ErrorCoding: String, LocalizedError {
        case error = "Unable to retrieve data."
    }
    
    // performing network request to iTunes Search, making sure it gets valid response
    let (data, response) = try await URLSession.shared.data(from: components.url!)
    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw ErrorCoding.error
    }
    // puts returned JSON data into format that is easier to read
    data.prettyPrintedJSONString()
    
    // decoding JSON into SearchResponse and returning [StoreItem]
    let jsonDecoder = JSONDecoder()
    let responseObject = try jsonDecoder.decode(SearchResponse.self, from: data)
    return responseObject.results
}

// calls func fetchItems
Task {
    do {
        let items = try await fetchItems(matching: [
            "term": "tame+impala",
            "entity": "album",
            "limit": "3"
        ])
    } catch {
        print("Fetch failed:", error.localizedDescription)
    }
}
