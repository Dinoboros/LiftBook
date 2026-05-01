//
//  LiftBookApp.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI
import SwiftData

@main
struct LiftBookApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            return try LiftBookPersistence.makeModelContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppLaunchView()
        }
        .modelContainer(sharedModelContainer)
    }
}
