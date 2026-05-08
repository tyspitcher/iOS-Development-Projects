//
//  EditDogView.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/22/26.
//

import SwiftUI

struct EditDogView: View {
    @Binding var dog: NamedDogs
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            dog.image
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .frame(maxWidth: .infinity, alignment: .center)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            HStack {
                Text("Edit Dog Name")
                    .padding(.horizontal, 20)
                    .font(.title3.bold())
                Spacer()
            }
            TextField("Edit name", text: $dog.name)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .autocorrectionDisabled(true)
            
            Button("Save") { dismiss() }
                .padding(7)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 3)
                )
                .padding(.horizontal, 50)
        }
        .padding()
    }
}

