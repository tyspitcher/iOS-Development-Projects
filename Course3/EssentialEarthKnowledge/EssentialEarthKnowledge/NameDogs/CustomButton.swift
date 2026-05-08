//
//  ShowAnotherDogButton.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/21/26.
//

import SwiftUI
struct CustomButton: ButtonStyle {
   func makeBody(configuration: Configuration) -> some View {
        let title = "Show Another Dog"
        return Label {
            Text(title)
        } icon: {
            Image(systemName: "dog")
        }
        .padding(7)
        .frame(maxWidth: .infinity)
        .foregroundStyle(.black)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 3)
        )
    }
}
