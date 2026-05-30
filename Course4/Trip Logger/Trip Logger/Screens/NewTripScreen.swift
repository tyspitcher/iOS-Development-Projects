//
//  NewTripView.swift
//  Trip Logger
//
//  Created by Jane Madsen on 4/29/25.
//

import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct NewTripScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State var tripName: String = ""
    @State var trip: Trip?
    var onFinish: () -> Void
    
    var body: some View {
        VStack {
            TextField("New Trip Name", text: $tripName)
            Spacer()
        }
        
        .navigationTitle("New Trip")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Next") {
                    let newTrip = Trip(name: tripName)
                    modelContext.insert(newTrip)
                    try? modelContext.save()
                    trip = newTrip
                }
                .tint(.blue)
                .disabled(tripName.isEmpty)
            }
        }
        
        .sheet(item: $trip) { trip in
                PlacePinScreen(
                    onFinish: onFinish,
                    trip: trip
                )
            }
        .padding(30)
        
    }
}
#Preview {
    NavigationStack {
        NewTripScreen(onFinish: {})
    }
    .modelContainer(ModelContainer.preview)
}
