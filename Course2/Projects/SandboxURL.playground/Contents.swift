import UIKit

var components = URLComponents(string: "https://api.nasa.gov/planetary/apod")!

components.queryItems = [
    "date": "2026-3-25",
    "api_key": "DEMO_KEY"
].map { URLQueryItem(name: $0.key, value: $0.value) }

Task {
    let (data, response) = try await URLSession.shared.data(from: components.url!)
    
    if let httpResponse = response as? HTTPURLResponse,
       httpResponse.statusCode == 200,
       let string = String(data: data, encoding: .utf8) {
        print(string)
    }
}

