//
//  ETGoHomeView.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/20/26.
//

import SwiftUI
struct ETGoHomeView: View {
    var body: some View {
        VStack {
            ScrollView {
                Text("About This App")
                    .font(.title.bold())
                    .padding(.bottom, 8)
                Text("Please select a tab below to get started learning the bare essential Earth knowledge. You'll explore very important topics such as naming interesting Earth animals called \"dogs\", finding local Earthling leaders, and more!")
                    .padding(.bottom, 25)
                Text("Need to phone home?")
                    .font(.title3.bold())
                    .padding(.bottom, 10)
                Text("We have conveniently listed the Earth items you'll need to create a 'phone home' device. Not sure where to get these items? Ask the nearest Earthling how to shop on Ebay. \n\n'Phone home' device shopping list: \n\n - Speak & Spell\n - umbrella\n - saw blade (circular)\n - coat hangers\n - metal forks\n - coffee can\n - record player\n - flashlight\n - wires and cords\n - toaster")
                    .padding(.bottom)
            }
            .padding(30)
        }
    }
}

#Preview {
    ETGoHomeView()
}
