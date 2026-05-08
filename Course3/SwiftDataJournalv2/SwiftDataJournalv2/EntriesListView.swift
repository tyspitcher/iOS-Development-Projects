//
//  EntriesListView.swift
//  SwiftDataJournalv2
//
//  Created by Tyson Pitcher on 4/27/26.
//
import Foundation
import SwiftUI
import SwiftData

struct EntriesListView: View {
    let journal: Journal
    @Environment(\.modelContext) private var modelContext
    @State private var entryToEdit: Entry?
    private var entries: [Entry] {
        journal.entries.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if entries.isEmpty {
                    Text("Tap the plus button to get started.")
                } else {
                    ForEach(entries) { entry in
                        NavigationLink {
                            AddEditEntryView(entry: entry, dismissOnDone: false)
                                .navigationTitle("Edit Entry")
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack {
                                Text(relativeDateFormatter.string(for: entry.updatedAt) ?? "")
                                Text(entry.title)
                            }
                        }
                    }
                    .onDelete(perform: deleteEntry)
                }
            }
            .navigationTitle(Text("\(journal.title)"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }

                ToolbarItem {
                    Button(action: addEntry) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $entryToEdit) { entry in
                NavigationStack {
                    AddEditEntryView(entry: entry, dismissOnDone: true)
                        .navigationTitle("New Entry")
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }

    private func addEntry() {
        let newEntry = Entry(title: "", body: "", journal: journal)
        modelContext.insert(newEntry)
        entryToEdit = newEntry
        try? modelContext.save()
    }
    
    private func deleteEntry(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
        try? modelContext.save()
    }
}
    
