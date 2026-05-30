//
//  PlacePinScreen.swift
//  Trip Logger
//
//  Created by Jane Madsen on 4/29/25.
//


import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct PlacePinScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State var journalEntry: JournalEntry?
    var onFinish: () -> Void
    var trip: Trip
    
    var body: some View {
        VStack {
            MapReader { reader in // Allows conversion of a touch gesture into coordinates
                Map {
                    // TODO: Display the pin the user placed
                    if let journalEntry, let coordinate = journalEntry.location.coordinate {
                        Marker(journalEntry.name, coordinate: coordinate)
                    }
                }
                .onTapGesture { location in
                    placePin(reader: reader, location: location)
                }
            }
        }
        .navigationTitle("Place First Pin")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Next") {
                    journalEntry = trip.journalEntries.last
                }
                .tint(.blue)
                .disabled(trip.journalEntries.isEmpty)
            }
        }
        .sheet(item: $journalEntry) { entry in
            SetUpPinScreen(
                journalEntry: journalEntry!,
                onSave: onFinish
            )
        }
        
    }
    
    func placePin(reader: MapProxy, location: CGPoint) {
        if let coordinate = reader.convert(location, from: .local) {
            let newEntry = JournalEntry(
                location: Location(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            )
            trip.journalEntries.append(newEntry)
            journalEntry = newEntry
        }
    }
}

#Preview {
    PlacePinScreen(
        onFinish: {},
        trip: Trip.mock()
    )
    .modelContainer(ModelContainer.preview)
}
