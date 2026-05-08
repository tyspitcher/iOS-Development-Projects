//
//  ThreadShareApp.swift
//  ThreadShare
//
//  Created by Tyson Pitcher on 5/4/26.
//

import SwiftUI
import SwiftData

@main
struct ThreadShareApp: App {
    private static let modelContainer: ModelContainer = {
        do {
            let configuration = ModelConfiguration(
                schema: SwiftDataThreadRepository.schema,
                isStoredInMemoryOnly: false
            )
            return try ModelContainer(
                for: SwiftDataThreadRepository.schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create ThreadShare SwiftData container: \(error)")
        }
    }()

    @StateObject private var appState: AppState = {
        let repository = SwiftDataThreadRepository(container: ThreadShareApp.modelContainer)
        return AppState(repository: repository)
    }()

    init() {
        ThreadShareFontRegistrar.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .modelContainer(Self.modelContainer)
        }
    }
}
