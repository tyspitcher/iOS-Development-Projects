/*:
## App Exercise - Workout API
 
 >These exercises reinforce Swift concepts in the context of a fitness tracking app.
 
 Your workout app now features a server-side API for users to upload and retrieve their workout data to use across multiple devices. For simplicity's sake, we will not be using a real API for this exercise. Below, an APIRequest protocol has been provided, alongside a sample implementation for a `GetUserRequest` API call.
 */
import Foundation

protocol APIRequest {
    associatedtype Response
    var urlRequest: URLRequest { get }
    func decodeResponse(data: Data) throws -> Response
}

struct User: Codable {
    let username: String
}

struct GetUserRequest: APIRequest {
    typealias Response = User
    let urlRequest: URLRequest
    
    init(username: String) {
        // Construct path to API call (base url omitted for simplicity's sake)
        var urlComponents = URLComponents()
        urlComponents.path = "/users"
        urlComponents.queryItems = [URLQueryItem(name: "username", value: username)]
        
        urlRequest = URLRequest(url: urlComponents.url!)
    }
    
    func decodeResponse(data: Data) throws -> User {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(User.self, from: data)
    }
}

//:  Below, a class for processing APIRequests has been started for you. The performRequest function uses a generic so that it can be called with any APIRequest, and will return the appropriate type specified by that request's Response type alias. Try calling the function: first, initialize a GetUserRequest, then call performRequest(_:), passing in the GetUserRequest you created and storing the result in a constant `user`. In a comment, answer: What type will `user` be, and where was that type derived from?

class WorkoutAPIService {
    func performRequest<R: APIRequest>(_ request: R) async throws -> R.Response {
        let (data, response) = try await URLSession.shared.data(for: request.urlRequest)

        // You can add HTTP status code validation here if needed:
        if let httpResponse = response as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            throw URLError(.badServerResponse)
        }

        return try request.decodeResponse(data: data)
    }
}
let request = GetUserRequest(username: "Tyson")
let service = WorkoutAPIService()
Task {
    do {
        let user = try await service.performRequest(request)
        print(user)
    } catch {
        print("Failed to fetch user: \(error)")
    }
}
// ** What type is returned? **
// 'user' Type will be 'User' because the typealias for
// GetUserRequest Response is User
//:  Create another struct, `GetRecentWorkoutRequest` that conforms to APIRequest. The url path should be "/workout/getLast/", with no query items needed. The response type should be `Workout`, which you will need to create as a struct as well; for simplicity's sake you can leave the struct empty with no parameters, but it will need to conform to Codable..
struct Workout: Codable { }

struct GetRecentWorkoutRequest: APIRequest {
    typealias Response = Workout
    let urlRequest: URLRequest
    init() {
        // Construct path to API call (base url omitted for simplicity's sake)
        var urlComponents = URLComponents()
        urlComponents.path = "/workout/getLast/"
        
        urlRequest = URLRequest(url: urlComponents.url!)
    }
    func decodeResponse(data: Data) throws -> Workout {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(Workout.self, from: data)
    }
}

//:  Try calling WorkoutAPIService.performRequest(_:) again, this time with your new GetRecentWorkoutRequest. In a comment, answer: What type will the function return this time, and where was that type derived from?
let workoutRequest = GetRecentWorkoutRequest()
let workoutService = WorkoutAPIService()
Task {
    do {
        let user = try await service.performRequest(request)
        print(user)
    } catch {
        print("Failed to fetch user: \(error)")
    }
}
// ** What type is returned? **
// the type this function will return will be a 'Workout' because
// the typealias for GetRecentWorkoutRequest() Response is Workout
/*:
 [Previous](@previous)  |  page 4 of 4
  */
