//
//  DragonDetailView.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/5/25.
//

import SwiftUI

struct DragonDetailView: View {
    @Environment(BackgroundSettings.self) var backgroundsettings
    @Environment(HomeRouter.self) var router
    var dragon: Dragon
    
    var body: some View {
        ZStack {
            backgroundsettings.backgroundColor
                .ignoresSafeArea()
            List {
                Section {
                    Text("Health: \(dragon.health)")
                    Text("Rating: \(dragon.rating)")
                    Button {
                        // TODO: Navigate to PowersListView for this dragon's powers
                        router.navigateTo(route: .powers(powers: dragon.powers))
                    } label: {
                        Text("Powers/Ablilities")
                    }
                }
                .font(.custom("Cochin", size: 40))
                .navigationTitle(dragon.name)
            }
            .scrollContentBackground(.hidden)
        }
    }
}


//#Preview {
//    DragonDetailView()
//}
