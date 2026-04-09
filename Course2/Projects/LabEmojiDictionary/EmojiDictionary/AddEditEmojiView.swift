//
//  AddEditEmojiView.swift
//  EmojiDictionary
//
//  Created by Jane Madsen on 10/30/25.
//
import SwiftUI

struct AddEditEmojiView: View {
    @Environment(\.dismiss) var dismiss
    @State var symbol: String
    @State var name: String
    @State var description: String
    @State var usage: String
    var emojiToEdit: Emoji?
    var onSave: (Emoji) -> Void

    init(emoji: Emoji?, onSave: @escaping (Emoji) -> Void) {
        _symbol = State(initialValue: emoji?.symbol ?? "")
        _name = State(initialValue: emoji?.name ?? "")
        _description = State(initialValue: emoji?.description ?? "")
        _usage = State(initialValue: emoji?.usage ?? "")
        self.emojiToEdit = emoji
        self.onSave = onSave
    }

    var isFormValid: Bool {
        !symbol.isEmpty && symbol.count == 1 && symbol.unicodeScalars.first?.properties.isEmojiPresentation == true &&
        !name.isEmpty && !description.isEmpty && !usage.isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Emoji", text: $symbol)
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                TextField("Usage", text: $usage)
            }
            .navigationTitle(emojiToEdit == nil ? "Add Emoji" : "Edit Emoji")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let emoji = Emoji(
                            id: emojiToEdit?.id ?? UUID(),
                            symbol: symbol,
                            name: name,
                            description: description,
                            usage: usage
                        )
                        onSave(emoji)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
