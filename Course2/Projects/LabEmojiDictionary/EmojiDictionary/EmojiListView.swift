//
//  ContentView.swift
//  EmojiDictionary
//
//  Created by Jane Madsen on 10/30/25.
//

import SwiftUI

// EmojiTableViewController

struct EmojiListView: View {
    @State var emojis: [Emoji] = []
    @State private var isShowingAddEdit = false
    @State private var editingEmoji: Emoji? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(emojis) { emoji in
                    Button {
                        editingEmoji = emoji
                        isShowingAddEdit = true
                    } label: {
                        EmojiRow(emoji: emoji)
                    }
                }
                .onDelete { indices in emojis.remove(atOffsets: indices) }
                .onMove { indices, newOffset in emojis.move(fromOffsets: indices, toOffset: newOffset) }
            }
            .navigationTitle("Emoji Dictionary")
            .toolbar {
                EditButton()
                Button("Add") {
                    editingEmoji = nil
                    isShowingAddEdit = true
                }
            }
            .sheet(isPresented: $isShowingAddEdit) {
                AddEditEmojiView(emoji: editingEmoji) { result in
                    if let index = emojis.firstIndex(where: { $0.id == result.id }) {
                        emojis[index] = result
                    } else {
                        emojis.append(result)
                    }
                    isShowingAddEdit = false
                }
                
            }
        }
        .onAppear {
            if emojis.isEmpty {
                Emoji.loadFromFile().forEach {
                    emojis.append($0)
                }
            }
        }
        .onChange(of: emojis) { oldValue, newValue in
            Emoji.saveToFile(emojis: newValue)
        }
    }
}

struct EmojiRow: View {
    let emoji: Emoji
    var body: some View {
        HStack {
            Text(emoji.symbol).font(.largeTitle)
            VStack(alignment: .leading) {
                Text(emoji.name).font(.headline)
                Text(emoji.description).font(.subheadline)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    EmojiListView()
}
