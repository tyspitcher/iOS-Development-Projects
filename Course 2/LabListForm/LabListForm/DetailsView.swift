//
//  ContentView.swift
//  LabListForm
//
//  Created by Tyson Pitcher on 3/2/26.
//

import SwiftUI

struct DetailsView: View {
    @State private var newMusicNotifications: Bool = false
    @State private var publicProfile: Bool = false
    @State private var fullName: String = ""
    @State private var userName: String = ""
    @State private var adventurousness: Double = 5
    @State private var newFeature: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                TextField("Full Name", text: $fullName)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled(true)
                
                
                TextField("Username", text: $userName)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            
            Section(header: Text("Preferences")) {
                Toggle("Make Profile Public", isOn: $publicProfile)
                
                Toggle("New Music Notifications", isOn: $newMusicNotifications)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Music Discovery")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(adventurousness))")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    
                    HStack {
                        Text("Conservative")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Slider(value: $adventurousness, in: 1...10, step: 1)
                            .tint(.orange)
                        Text("Adventurous")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Lower favors familiar artists and eras. Higher explores more genres and time periods.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Section(header: Text("Suggest New Features")) {
                TextEditor(text: $newFeature)
                    .frame(minHeight: 120)            // make it larger
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled(false)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                    .padding(.vertical, 4)

                Text("We are always looking to improve. Your feedback is invaluable!")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .scrollContentBackground(.hidden)
            .listStyle(.automatic)
        }
        .padding()
        .background(LinearGradient(
            colors: [.green, .blue, .red],
            startPoint: .top,
            endPoint: .bottom))
    }
}

#Preview {
    DetailsView()
}
