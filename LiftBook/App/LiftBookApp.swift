//
//  LiftBookApp.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI
import SwiftData

@main
struct LiftBookApp: App {
    @State private var router = AppRouter()
    @AppStorage("isFirstLaunch") private var isFirstLaunch = false

    var modelContainer: ModelContainer {
        let schema = Schema([
            Exercise.self,
            ExerciseSet.self,
            Workout.self
        ])

        // let appGroupID = "group.com.dinoboros.LiftBook"
        // let url = FileManager.default
        // .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?.appendingPathComponent("liftbook.store")

        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isFirstLaunch {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .environment(router)
            .modelContainer(modelContainer)
        }
    }
}
