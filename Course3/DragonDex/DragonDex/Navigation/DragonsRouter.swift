//
//  DragonsRouter.swift
//  DragonDex
//
//  Created by Logan Steven Bartell on 12/4/25.
//
import Foundation
import SwiftUI

// TODO: Create a Navigation Router for navigating Dragon views

@Observable
class HomeRouter {
    var navigationPath = NavigationPath()
    
    enum Route: Hashable {
        case settings
        case powers(powers: [Power])
        case dragonDetail(dragon: Dragon)
    }
    @ViewBuilder
    func view(for route: Route) -> some View {
        switch route {
        case .settings:
            SettingsSheetView()
        case .powers(let powers):
            PowersView(powers: powers)
        case .dragonDetail(let dragon):
            DragonDetailView(dragon: dragon)
        }
    }
    func navigateTo(route: Route) {
        navigationPath.append(route)
    }
}
