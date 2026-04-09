
import UIKit

//           ******    iTunes Search (Part 1)    *****

var components = URLComponents(string: "https://itunes.apple.com/lookup")!

components.queryItems = [
    "id": "290242959", // Tame Impala ID
    "entity": "album", // search albums
    "limit": "3" // top 3 albums = Currents, The Slow Rush, InnerSpeaker
].map { URLQueryItem(name: $0.key, value: $0.value) }

Task {
    let (data, response) = try await URLSession.shared.data(from: components.url!)
    
    if let httpResponse = response as? HTTPURLResponse,
       httpResponse.statusCode == 200,
       let string = String(data: data, encoding: .utf8) {
        print(string)
    }
}

extension Data {
    func prettyPrintedJSONString() {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: self, options: []),
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyJSONString = String(data: jsonData, encoding: .utf8) else {
            print ("Failed to read JSON Object.")
            return
        }
    }
}
