//
//  TakeMeToYourLeaderView.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/21/26.
//

import SwiftUI

struct TakeMeToYourLeaderView: View {
    let representativeController: any RepresentativeAPIControllerProtocol
    @State private var showTakeMeToYourLeaderSheet: Bool = false
    @State private var searchText = ""
    @State private var leaders: [LeaderInfo] = []
    @State private var errorMessage: String? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                infoButton
                Section {
                    TextField("Enter Local Zip Code", text: $searchText)
                        .onSubmit { searchForLeader() }
                }
                Section("Leaders") {
                    ForEach(leaders) { leader in
                        row(for: leader)
                        .padding(.vertical, 4)
                    }
                }
            }
            .buttonStyle(.borderless)
            .sheet(isPresented: $showTakeMeToYourLeaderSheet) {
                TakeMeToYourLeaderSheet()
            }
        }
    }
    
    @ViewBuilder
    var infoButton: some View {
        Button {
            showTakeMeToYourLeaderSheet = true
        } label: {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                Text("About Finding a Leader")
            }
        }
    }
    
    @ViewBuilder
    func row(for leader: LeaderInfo) -> some View {
        VStack(alignment: .leading) {
            // Apply 'Junior Representative' only for Mitt Romney
            Text(leader.name == "Mitt Romney"
                 ? "Junior Representative"
                 : "")
            .font(.headline)
            HStack {
                Image(systemName: "person.fill")
                    .padding(.horizontal, 2)
                Text(leader.name)
                    .font(.headline)
            }
            HStack(alignment: .top) {
                Image(systemName: "building.columns")
                Text(leader.office)
                    .font(.subheadline)
            }
            HStack {
                Image(systemName: "phone")
                    .padding(.horizontal, 1)
                Text(leader.phone)
                    .font(.subheadline)
            }
            HStack {
                Image(systemName: "desktopcomputer")
                Link(leader.website, destination: URL(string: leader.website)!)
                    .font(.subheadline)
            }
        }
    }
    
    func searchForLeader() {
        Task {
            do {
                leaders = try await representativeController.fetchLeaderInfo(matching: ["zip": searchText, "output": "json"]
                )
                errorMessage = nil
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    TakeMeToYourLeaderView(representativeController: TakeMeToYourLeaderController())
}
