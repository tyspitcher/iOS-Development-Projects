//
//  JournalsListView.swift
//  SwiftDataJournalv2
//
//  Created by Tyson Pitcher on 4/28/26.
//

import Foundation
import SwiftUI
import SwiftData

struct JournalsListView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var editMode: EditMode = .inactive
    @State private var journalToEdit: Journal?
    @State private var selectedJournalID: String?

    @Query private var journals: [Journal]

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedJournalID) {
                if journals.isEmpty {
                    Text("Tap plus button to start new journal")
                } else {
                    ForEach(journals) { journal in
                        if editMode.isEditing {
                            Button {
                                journalToEdit = journal
                            } label: {
                                journalRow(for: journal)
                            }
                            .buttonStyle(.plain)
                            .contentShape(Rectangle())
                        } else {
                            NavigationLink(value: journal.id) {
                                journalRow(for: journal)
                            }
                        }
                    }
                    .onDelete(perform: deleteJournal)
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("Journals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(editMode.isEditing ? "Done" : "Edit") {
                        editMode = editMode.isEditing ? .inactive : .active
                    }
                }

                ToolbarItem {
                    Button(action: addJournal) {
                        Label("Add Journal", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $journalToEdit) { journal in
                NavigationStack {
                    AddEditJournalView(journal: journal) {
                        editMode = .inactive
                        journalToEdit = nil
                    }
                    .navigationTitle("Edit Journal")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        } detail: {
            if let selectedJournalID,
               let selectedJournal = journals.first(where: { $0.id == selectedJournalID }) {
                EntriesListView(journal: selectedJournal)
            } else {
                Text("Select a journal")
            }
        }
    }

    private func journalRow(for journal: Journal) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(journal.title)
                Text("entries: \(journal.entries.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(relativeDateFormatter.string(for: journal.createdAt) ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func addJournal() {
        let newJournal = Journal(title: "")
        modelContext.insert(newJournal)
        journalToEdit = newJournal
        try? modelContext.save()
    }

    private func deleteJournal(offsets: IndexSet) {
        let deletedIDs = offsets.map { journals[$0].id }

        for index in offsets {
            modelContext.delete(journals[index])
        }

        if let selectedJournalID, deletedIDs.contains(selectedJournalID) {
            self.selectedJournalID = nil
        }

        try? modelContext.save()
    }
}


