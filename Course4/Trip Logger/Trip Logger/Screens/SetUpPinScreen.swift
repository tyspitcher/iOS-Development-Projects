//
//  SetUpPinScreen.swift
//  Trip Logger
//
//  Created by Jane Madsen on 4/29/25.
//


import SwiftUI
import SwiftData
import MapKit
import PhotosUI

struct SetUpPinScreen: View {
    @Bindable var journalEntry: JournalEntry
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var onSave: () -> Void = {}
    
    var body: some View {
        
        VStack {
            Text("Name your first pin, add photos, and add notes to this stop")
                .font(.title2.bold())
                .padding(20)
            
            TextField("Journal Entry Title", text: $journalEntry.name)
                .font(.title3.bold())
                .padding(.horizontal, 35)
            
            ScrollView {
                TextEditor(text: $journalEntry.text)
                    .frame(minHeight: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 30)
                
            }
            PhotoScrollView(journalEntry: journalEntry)
                .padding(20)
        }
        
        Button("Save") {
            try? modelContext.save()
            onSave()
            dismiss()
        }
        .font(Font.title.bold())
        .buttonStyle(.bordered)
        
    }
}

#Preview {
    let trip = Trip.mock()
    SetUpPinScreen(journalEntry: trip.journalEntries.first!)
        .modelContainer(ModelContainer.preview)
}
