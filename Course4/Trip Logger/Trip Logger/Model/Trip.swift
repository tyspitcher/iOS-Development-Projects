//
//  Trip.swift
//  Trip Logger
//
//  Created by Jane Madsen on 4/17/25.
//

import Foundation
import MapKit
import SwiftData

@Model
final class Trip {
    var id: UUID
    var name: String
    var journalEntries: [JournalEntry]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.journalEntries = []
    }
}

extension Trip {
    static func mock() -> Trip {
        let trip = Trip(name: "France 2025")
  
        let paris = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 48.856788,
                longitude: 2.351077
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.15,
                longitudeDelta: 0.15
            )
        )

        let journalEntry = JournalEntry(name: "Museum", location: Location(region: paris), text: "What a great time we had, oh boy. There was a great little restaurant inside the museum and they had the best food. I had probably the best eclaire of my life, which is crazy that it was in a museum and not at a fine bakery (of which there are many around here). I also had a great view of the Eiffel Tower. We are running late, so we won't be able to do everything we want on the other side of Paris, but I'm sure I'll be back in time for the Louvre.")
        
        trip.journalEntries.append(journalEntry)
        
        return trip
    }
}

extension ModelContainer {
    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(
            for: Trip.self,
            configurations: ModelConfiguration(
                isStoredInMemoryOnly: true
            )
        )

        let trip = Trip.mock()
        
        container.mainContext.insert(trip)

        return container
    }
}
