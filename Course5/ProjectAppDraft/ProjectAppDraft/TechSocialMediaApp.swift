//
//  TechSocialMediaApp.swift
//  ProjectAppDraft
//
//  Created by Tyson Pitcher on 3/30/26.
//
import SwiftUI

@main
struct TechSocialMediaApp: App {
    var body: some Scene {
        WindowGroup {
            ParentTabView(viewModel: ParentTabViewModel(user: tyson))
        }
    }
}
