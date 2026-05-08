//
//  NameDogsView.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/21/26.
//

import SwiftUI

struct NameDogsView: View {
    let photoController: any DogAPIControllerProtocol
    @State private var errorMessage: String? = nil
    @State private var image: Image? = nil
    @State private var dogName: String = ""
    @State private var dogsWithNames: [NamedDogs] = []
    @State private var showNameDogsInstructions: Bool = false
    @State private var selectedDogID: NamedDogs.ID? = nil
    var body: some View {
        NavigationStack {
            Form {
                Button {
                    showNameDogsInstructions = true
                } label: {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("About Naming Dogs")
                    }
                }
                Section {
                    if let errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.octagon")
                            Text(errorMessage)
                                .font(.title3)
                        }
                    } else if let image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                    } else {
                        ProgressView()
                    }
                }
                HStack {
                    TextField("Name?", text: $dogName)
                        .onSubmit {
                            addCurrentDogToList()
                            Task { await loadPhoto() }
                        }
                        .autocorrectionDisabled(true)
                }
                DogListCell(dogsWithNames: dogsWithNames) { tappedDog in
                    selectedDogID = tappedDog.id
                }
            }
            Button("Show Another Dog") {
                addCurrentDogToList()
                Task { await loadPhoto() }
            }
            .buttonStyle(CustomButton())
            .padding(.horizontal, 50)
            .padding(.bottom, 10)
            .task {
                await loadPhoto()
            }
        }
        .sheet(isPresented: $showNameDogsInstructions) {
            NameDogsSheet()
        }
        .sheet(
            isPresented: Binding(
                get: { selectedDogID != nil },
                set: { if !$0 { selectedDogID = nil } }
            )
        ) {
            if let selectedDogID,
               let index = dogsWithNames.firstIndex(where: { $0.id == selectedDogID }) {
                EditDogView(dog: $dogsWithNames[index])
            } else {
                Text("Dog not found")
            }
        }
    }
    
    func loadPhoto() async {
        do {
            let fetchedImage = try await photoController.fetchDogPhoto()
            image = fetchedImage
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func addCurrentDogToList() {
        let trimmedName = dogName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, let image else { return }
        
        dogsWithNames.append(NamedDogs(image: image, name: trimmedName))
        dogName = ""
    }
}

#Preview {
    NameDogsView(photoController: DogAPIController())
}
