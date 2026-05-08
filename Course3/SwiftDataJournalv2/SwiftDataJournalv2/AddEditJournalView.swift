//
//  AddEditJournalView.swift
//  SwiftDataJournalv2
//
//  Created by Tyson Pitcher on 4/28/26.
//

import Foundation
import SwiftUI
import SwiftData

struct AddEditJournalView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var journal: Journal
    var onDone: () -> Void = {}

    var body: some View {
        Form {
            Section {
                TextField("Journal Name", text: $journal.title)
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    try? modelContext.save()
                    onDone()
                    dismiss()
                }
            }
        }
    }
}
