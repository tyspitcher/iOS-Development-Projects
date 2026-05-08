//
//  RiderListView.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/4/25.
//

import SwiftUI

struct RiderListView: View {
    @Environment(BackgroundSettings.self) var backgroundSettings
    var body: some View {
        ZStack {
            backgroundSettings.backgroundColor
                .ignoresSafeArea()
            Text("Riders")
        }
    }
}

//#Preview {
//    RiderListView()
//}
