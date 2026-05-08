//
//  AddEditEntryView.swift
//  SwiftDataJournalv2
//
//  Created by Tyson Pitcher on 4/27/26.
//

import Foundation
import SwiftUI
import SwiftData

struct AddEditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var entry: Entry
    @State private var didSave = false
    var dismissOnDone: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section {
                    TextField("Title", text: $entry.title)
                }
                Section {
                    TextEditor(text: $entry.body)
                        .frame(minHeight: 400)
                }
            }
        }
        
        .toolbar {
            ToolbarItem() {
                Button {
                    entry.updatedAt = Date()
                    try? modelContext.save()
                    didSave = true
                    if dismissOnDone {
                        dismiss()
                    }
                } label: {
                    if didSave {
                        Image(systemName: "checkmark")
                    } else {
                        Text("Save")
                    }
                }
            }
        }
    }
}
