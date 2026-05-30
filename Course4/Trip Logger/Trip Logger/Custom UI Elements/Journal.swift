//
//  Journal.swift
//  Trip Logger
//
//  Created by Jane Madsen on 4/29/25.
//


import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct Journal: View {
    @Binding var journalEntry: JournalEntry?
    @State var entryToEdit: JournalEntry?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            JournalTopBar(journalEntry: $journalEntry)
                .padding()
            
            if let journalEntry {
                Text(journalEntry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.headline)
                Text(journalEntry.text)
                    .font(.body)
                
                PhotoScrollView(journalEntry: journalEntry)
            }
        }
        .padding()
    }
}



struct JournalTopBar: View {
    @Binding var journalEntry: JournalEntry?
    @State var entryToEdit: JournalEntry?
    
    var body: some View {
        HStack {
            Button("Edit") {
                // TODO: Add ability to edit journal entries
                entryToEdit = journalEntry
                
            }
            
            Spacer()
            
            Text(journalEntry?.name ?? "Journal")
                .font(.title)
            
            Spacer()
            
            Button("Dismiss") {
                journalEntry = nil
            }
        }
        .sheet(item: $entryToEdit) { entry in
            JournalEntryEditor(journalEntry: entry)
        }
    }
}

// sheet to edit journal entries
struct JournalEntryEditor: View {
    @Bindable var journalEntry: JournalEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Journal Entry Title") {
                    TextField("Title", text: $journalEntry.name)
                }

                Section("Journal Entry") {
                    TextEditor(text: $journalEntry.text)
                        .frame(minHeight: 200)
                }

                Section("Photos") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(journalEntry.photos) { photo in
                                if let uiImage = UIImage(data: photo.data) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipped()
                                            .cornerRadius(12)

                                        Button {
                                            journalEntry.photos.removeAll { $0.id == photo.id }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(.white, .red)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    PhotoScrollView(journalEntry: journalEntry)
                }
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
#Preview {
    @Previewable @State var trip = Trip.mock()
    
    TripMapScreen(trip: trip, position: .automatic, selectedEntry: trip.journalEntries.first)
}
