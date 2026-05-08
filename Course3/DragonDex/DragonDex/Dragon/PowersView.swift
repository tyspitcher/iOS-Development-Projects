//
//  PowersView.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/5/25.
//

import SwiftUI

struct PowersView: View {
    @Environment(BackgroundSettings.self) var backgroundsettings
    
    let powers: [Power]
    
    var body: some View {
        ZStack {
            backgroundsettings.backgroundColor
                .ignoresSafeArea()
            List {
                ForEach(powers) { power in
                    Section {
                        Text("Energy Cost: \(power.energyCost)")
                        Text(power.description)
                    } header: {
                        Text(power.name)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
    }
}

