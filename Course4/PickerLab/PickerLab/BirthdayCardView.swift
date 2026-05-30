//
//  BirthdayCardView.swift
//  PickerLab
//
//  Created by Tyson Pitcher on 5/18/26.
//

import SwiftUI

struct BirthdayCardView: View {
    let partyDescription: String
    let selectedDate: Date
    let image: Image?
    let locationAddress: String
    
    var body: some View {
        VStack {
            Spacer()
            Text("You're Invited to a Birthday Party!")
                .font(.title2.bold())
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 220)
                    .cornerRadius(10)
            }
            Text(partyDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("When:")
                .font(.headline)
            Text(selectedDate, format: .dateTime.month().day().hour().minute())
                .font(.title3)
                .padding(.bottom)
            
            Text("Where:")
                .font(.headline)
            Text(locationAddress)
                .font(.title3)
            
            Spacer()
            
            // create link to share card
            let shareText = """
            You're Invited to a Birthday Party!
            \(partyDescription)
            \(selectedDate.formatted(date: .abbreviated, time: .shortened))
            """
            ShareLink(item: shareText) {
                Text("Share Invitation")
            }
        }
        .padding()
    }
}

