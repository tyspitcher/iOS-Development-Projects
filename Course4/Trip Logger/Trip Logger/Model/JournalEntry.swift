//
//  PointOfInterest.swift
//  Trip Logger
//
//  Created by Jane Madsen on 4/16/25.
//

import Foundation
import SwiftData
import SwiftUI
import MapKit

@Model
class JournalEntry: Identifiable {
    var id: UUID
    var trip: Trip?
    var name: String
    var location: Location
    var photos: [Photo]
    var date: Date
    var text: String
    
    init(id: UUID = UUID(), name: String = "", location: Location = Location(), photos: [Photo] = [], date: Date = Date(), text: String = "") {
        self.id = id
        self.name = name
        self.location = location
        self.photos = photos
        self.date = date
        self.text = text
    }
}

@Model
class Location {
    var latitude: Double?
    var longitude: Double?
    var latitudeDelta: Double?
    var longitudeDelta: Double?
    
    init(latitude: Double? = nil, longitude: Double? = nil, latitudeDelta: Double? = nil, longitudeDelta: Double? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
    init(region: MKCoordinateRegion) {
        self.latitude = region.center.latitude
        self.longitude = region.center.longitude
        self.latitudeDelta = region.span.latitudeDelta
        self.longitudeDelta = region.span.longitudeDelta
    }
    
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var mapItem: MKMapItem? {
        if let coordinate {
            return MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        } else {
            return nil
        }   
    }
}

struct Photo: Codable, Identifiable {
    var id = UUID()
    var data: Data
}
