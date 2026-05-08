//
//  DogAPIController.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/21/26.
//
import SwiftUI
import Foundation

protocol DogAPIControllerProtocol {
    func fetchDogPhoto() async throws -> Image
}

@MainActor
class DogAPIController: DogAPIControllerProtocol {
    struct DogAPIResponse: Codable {
        let message: URL
        let status: String
    }
    
    enum DogPhotoError: Error, LocalizedError {
        case itemNotFound
        case imageDataMissing
    }
    
    func fetchDogPhoto() async throws -> Image {
        let DogApiURL = URL(string: "https://dog.ceo/api/breeds/image/random")!
        let (JsonData, DataResponse) = try await URLSession.shared.data(from: DogApiURL)
        
        guard let httpResponse = DataResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw DogPhotoError.itemNotFound
        }
        
        let decoder = JSONDecoder()
        let api = try decoder.decode(DogAPIResponse.self, from: JsonData)
        let imageURL = api.message
        
        let (imageData, imageResponse) = try await URLSession.shared.data(from: imageURL)
        guard let imageHTTP = imageResponse as? HTTPURLResponse, imageHTTP.statusCode == 200 else {
            throw DogPhotoError.imageDataMissing
        }
        
        guard let uiImage = UIImage(data: imageData) else {
            throw DogPhotoError.imageDataMissing
        }
        
        return Image(uiImage: uiImage)
    }
}
