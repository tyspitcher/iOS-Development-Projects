//
//  ContentView.swift
//  iTunesSearch
//
//  Created by Jane Madsen on 11/3/25.
//

import SwiftUI

@Observable
@MainActor
class StoreItemListViewModel {
    var items: [StoreItem] = []
    let itemController = StoreItemController()
    var searchText = ""
    var selectedMediaType: MediaType = .music
    var previewTask: Task<Void, Never>? = nil
    
    func fetchPreview(item: StoreItem) {
        if let previewTask {
            previewTask.cancel()
        }
        
        previewTask = Task {
            // Code to fetch the preview data using the URL
            do {
                guard let previewURL = item.previewURL else { return }
                _ = try await itemController.fetchPreview(from: previewURL)
            } catch {
                print("Fetch failed:", error)
        }
    }
    // Once the task is complete, return the stored task value to nil
    previewTask = nil

    }
    func fetchMatchingItems() {
        guard !searchText.isEmpty else {
            // set up query dictionary
            items = []
            return
        }
        // use the item controller to fetch items
        // if successful, use the main queue to set self.items
        // otherwise, print an error to the console
        Task {
            do {
                items = try await itemController.fetchItems(matching: [
                    "media": selectedMediaType.rawValue,
                    "term": searchText
                ])
            } catch {
                print("Fetch failed:", error)
                items = []
            }
        }
    }
}

struct StoreItemListView: View {
    @State private var viewModel = StoreItemListViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Media Type", selection: $viewModel.selectedMediaType) {
                    ForEach(MediaType.allCases, id: \.self) { mediaType in
                        Text(mediaType.rawValue.capitalized)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.horizontal, .top])
                .onChange(of: viewModel.selectedMediaType) { oldValue, newValue in
                      viewModel.fetchMatchingItems()
                  }

                HStack {
                    TextField("Search...", text: $viewModel.searchText) {
                        viewModel.fetchMatchingItems()
                        // onCommit
                        // When the user hits Return on their keyboard, this closure will trigger
                        
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .submitLabel(.search)
                    .padding([.horizontal, .bottom])
                }
                
                List(viewModel.items, id: \.id) { item in
                    ItemCellView(item: item) {
                        viewModel.fetchPreview(item: item)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("iTunes Search")
            .onAppear {
                viewModel.fetchMatchingItems()
            }
        }
    }
}

#Preview {
 StoreItemListView()
}
