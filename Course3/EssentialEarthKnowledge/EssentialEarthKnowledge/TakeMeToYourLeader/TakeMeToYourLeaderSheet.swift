//
//  TakeMeToYourLeaderSheet.swift
//  EssentialEarthKnowledge
//
//  Created by Tyson Pitcher on 4/20/26.
//

import SwiftUI

struct TakeMeToYourLeaderSheet: View {
    var body: some View {
        VStack {
            ScrollView {
                Text("\"Take Me To Your Leader\"")
                    .font(.title.bold())
                    .padding(.vertical)
                Text("Earthlings understand that the most pressing issue that every newly arrived alien has on their mind is \"Take me to your leader.\" Well, we have created a tool to make it very easy for you to locate a local earthling leader. Simply ask a nearby Earthling which zip code you are in, and type in the number they tell you to find a local Earthling leaders. Then you can simply take yourself to our leader!")
                    .font(.body)
            }
            .padding(25)
        }
    }
}

#Preview {
    TakeMeToYourLeaderSheet()
}
