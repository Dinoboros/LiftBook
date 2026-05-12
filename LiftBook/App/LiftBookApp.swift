//
//  LiftBookApp.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct LiftBookApp: App {
    var sharedModelContainer: ModelContainer = {
        do {
            return try LiftBookPersistence.makeModelContainer()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        UNUserNotificationCenter.current().delegate = RestTimerNotificationCenterDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            AppLaunchView()
                .environment(
                    \.restTimerNotificationCoordinator,
                    RestTimerNotificationCoordinator.shared
                )
        }
        .modelContainer(sharedModelContainer)
    }
}
