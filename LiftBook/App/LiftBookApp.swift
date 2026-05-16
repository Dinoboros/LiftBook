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
    @State private var persistenceState: PersistenceState = .loading

    init() {
        AppMonitoring.initialize()
        UNUserNotificationCenter.current().delegate = RestTimerNotificationCenterDelegate.shared
    }

    var body: some Scene {
        WindowGroup {
            rootView
                .task {
                    loadPersistentStoreIfNeeded()
                }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        switch persistenceState {
        case .loading:
            ProgressView("Opening LiftBook")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LBColor.background.ignoresSafeArea())

        case .ready(let modelContainer):
            AppLaunchView()
                .environment(
                    \.restTimerNotificationCoordinator,
                    RestTimerNotificationCoordinator.shared
                )
                .modelContainer(modelContainer)

        case .failed(let error):
            PersistenceRecoveryView(
                error: error,
                onRetry: loadPersistentStore,
                onReset: resetPersistentStore
            )
        }
    }

    @MainActor
    private func loadPersistentStoreIfNeeded() {
        guard case .loading = persistenceState else {
            return
        }

        loadPersistentStore()
    }

    @MainActor
    private func loadPersistentStore() {
        do {
            let modelContainer = try LiftBookPersistence.makeModelContainer()
            persistenceState = .ready(modelContainer)
        } catch {
            persistenceState = .failed(error)
        }
    }

    @MainActor
    private func resetPersistentStore() {
        do {
            try LiftBookPersistence.deletePersistentStore()
            UserDefaults.standard.set(false, forKey: LBSettingsKeys.hasCompletedOnboarding)
            Task {
                await RestTimerNotificationService().cancelAllRestTimerNotifications()
            }
            loadPersistentStore()
        } catch {
            persistenceState = .failed(error)
        }
    }
}

private enum PersistenceState {
    case loading
    case ready(ModelContainer)
    case failed(Error)
}
