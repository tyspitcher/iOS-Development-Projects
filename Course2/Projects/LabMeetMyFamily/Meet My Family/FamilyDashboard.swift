//
//  ContentView.swift
//  Meet My Family
//
//  Created by Tyson Pitcher on 3/5/26.
//

import SwiftUI
import Foundation

struct FamilyDashboard: View {
    let members: [FamilyMember] = familyMembers
    @State private var checkViewedNames: Set<String> = []
    @State private var showModal: FamilyMember? = nil

    var body: some View {
        NavigationStack {
            List(members) { member in
                Button {
                    showModal = member
                    checkViewedNames.insert(member.name)
                } label: {
                    FamilyMemberView(
                        member: member,
                        isSelected: .constant(checkViewedNames.contains(member.name)),
                        selectionEmoji: "✅"
                    )
                }
                .buttonStyle(.glass(.clear))
            }
            .navigationTitle("The Pitcher Family")
            .sheet(item: $showModal) { member in
                FamilyMemberDetailView(member: member)
            }
        }
    }
}


struct FamilyMemberDetailView: View {
    let member: FamilyMember
    
    var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Image(member.photoAssetName)
                    .resizable()
                    .frame(height: 340)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                
                Text(member.name)
                    .font(.custom("Impact", size: 60))
                
                VStack(alignment: .leading) {
                    Text("Hobbies:\(member.hobbies)\n")
                    Text("Favorite foods: \(member.foods)\n")
                    Text("Favorite artist or bands: \(member.bandsOrMusicians)\n")
                    Text("Favorite places: \(member.places)")
                }
                .font(.body)
            }
            .padding()
            .padding()
        Spacer()
        }
    }


#Preview {
    FamilyDashboard()
}
