//
//  DogListCell.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/21/26.
//

import SwiftUI

struct NamedDogs: Identifiable {
    let id = UUID()
    let image: Image
    var name: String
}

struct DogListCell: View {
    let dogsWithNames: [NamedDogs]
    let onTapDog: (NamedDogs) -> Void
    
    var body: some View {
        ForEach(dogsWithNames) { dog in
            HStack(spacing: 12) {
                dog.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                Text(dog.name)
                    .font(.title2.bold())
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTapDog(dog)
            }
            .padding(.horizontal, 20)
        }
    }
}
