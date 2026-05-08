//
//  NameDogsSheet.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/20/26.
//

import SwiftUI

struct NameDogsSheet: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("More About Naming Dogs")
                    .font(.title)
                    .bold()
                    .padding(.vertical)
                Text("Almost certainly, the first thing you'll see here on Earth is an Eartlings feeding, entertaining, or cleaning up the waste of a four-legged creature. It may appear that these creatures are using Earthling humans as their servants. Well, these four-legged creatures are called \"dogs\", and the surprising reality is that the humans actually the ones who own the dogs, and not the other way around. If you want to be able to relate to Earthlings, it is essential for you to be able to name these fascinating creatures. ")
                    .font(.body)
            }
            .padding(25)
        }
    }
}

#Preview {
    NameDogsSheet()
}
