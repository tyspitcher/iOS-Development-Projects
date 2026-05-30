//
//  CreateCardView.swift
//  PickerLab
//
//  Created by Tyson Pitcher on 5/18/26.
//

import SwiftUI
import PhotosUI

struct CreateCardView: View {
    @State var partyDescription: String = ""
    @State var selectedDate: Date = .now
    @State var selectedPhoto: PhotosPickerItem? = nil
    @State var image: Image?
    @State var showBirthdayCard: Bool = false
    @State var locationAddress: String = ""
    
    let oneYear = Calendar.current.date(byAdding: DateComponents(day: 365), to: Date.now)!
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section {
                    TextEditor(text: $partyDescription)
                        .frame(height: 80)
                } header: {
                    Text("Write Party Description")
                }
                
                Section {
                    PhotosPicker("Select Photo", selection: $selectedPhoto, matching: .images)
                        .onChange(of: selectedPhoto) {
                            oldValue, newValue in
                            handleSinglePhotoChange(newValue)
                        }
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 315)
                            .cornerRadius(8)
                            .padding(.vertical)
                    }
                } header: {
                    Text("Choose Photo for Card")
                }
                
                Section {
                    DatePicker(selection: $selectedDate, in:
                                Date()...oneYear) {
                        Text("Select Date")
                    }
                } header: {
                    Text("Select Party Date and Time")
                }
                
                Section {
                    TextEditor(text: $locationAddress)
                        .frame(height: 80)
                } header: {
                    Text("Party Location Address")
                }
                
                Section {
                    Button("Create Birthday Card") {
                        showBirthdayCard = true
                            }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("Create Invitation")
            .navigationDestination(isPresented: $showBirthdayCard) {
                BirthdayCardView(
                    partyDescription: partyDescription,
                    selectedDate: selectedDate,
                    image: image,
                    locationAddress: locationAddress
                )
            }
        }
    }
    
    func handleSinglePhotoChange(_ newValue: PhotosPickerItem?) {
        Task {
            if let newValue {
                if let data = try? await newValue.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    self.image = Image(uiImage: uiImage)
                } else {
                    self.image = nil
                }
            }
        }
    }
}

struct DisplayImage: Identifiable {
    var id: UUID = UUID()
    var image: Image
}

#Preview {
    CreateCardView()
}
