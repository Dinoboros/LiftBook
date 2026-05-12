//
//  AppLaunchView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import SwiftData
import SwiftUI

struct AppLaunchView: View {
    private static let splashDuration: TimeInterval = 2

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.restTimerNotificationService) private var restTimerNotificationService

    @State private var launchPhase: AppLaunchPhase = .splash
    @State private var hasPreparedUITestData = false

    var body: some View {
        ZStack {
            if launchPhase == .splash {
                LaunchSplashView(duration: Self.splashDuration)
                    .transition(.opacity)
            } else {
                appContent
                    .transition(.opacity)
            }
        }
        .background(LBColor.background.ignoresSafeArea())
        .task {
            prepareUITestDataIfNeeded()
            await finishSplash()
            await requestRestTimerNotificationPermissionIfNeeded()
        }
    }

    @ViewBuilder
    private var appContent: some View {
        if hasCompletedOnboarding || shouldSkipOnboardingForUITesting {
            HomeView()
        } else {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        }
    }

    @MainActor
    private func finishSplash() async {
        guard launchPhase == .splash else {
            return
        }

        if shouldSkipSplashForUITesting {
            launchPhase = .ready
            return
        }

        do {
            let nanoseconds = UInt64(Self.splashDuration * 1_000_000_000)
            try await Task.sleep(nanoseconds: nanoseconds)
        } catch {
            return
        }

        withAnimation(.easeInOut(duration: reduceMotion ? 0.12 : 0.28)) {
            launchPhase = .ready
        }
    }

    private var shouldSkipSplashForUITesting: Bool {
        processArguments.contains("-uiTestingSkipSplash")
    }

    private var shouldSkipOnboardingForUITesting: Bool {
        processArguments.contains("-uiTestingSkipOnboarding")
    }

    private var shouldResetDataForUITesting: Bool {
        processArguments.contains("-uiTestingResetData")
    }

    private var isRunningUITests: Bool {
        shouldSkipSplashForUITesting
            || shouldSkipOnboardingForUITesting
            || shouldResetDataForUITesting
    }

    private var processArguments: [String] {
        ProcessInfo.processInfo.arguments
    }

    @MainActor
    private func prepareUITestDataIfNeeded() {
        guard shouldResetDataForUITesting, !hasPreparedUITestData else {
            return
        }

        hasPreparedUITestData = true

        do {
            try deleteAll(WorkoutSession.self)
            try deleteAll(RoutineTemplate.self)
            try deleteCustomExercises()
            try modelContext.save()
        } catch {
            assertionFailure("Could not reset UI test data: \(error)")
        }
    }

    private func requestRestTimerNotificationPermissionIfNeeded() async {
        guard !isRunningUITests else {
            return
        }

        _ = await restTimerNotificationService.requestAuthorizationOnFirstLaunchIfNeeded()
    }

    @MainActor
    private func deleteAll<T: PersistentModel>(_ modelType: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let models = try modelContext.fetch(descriptor)

        for model in models {
            modelContext.delete(model)
        }
    }

    @MainActor
    private func deleteCustomExercises() throws {
        let descriptor = FetchDescriptor<Exercise>(
            predicate: #Predicate<Exercise> { exercise in
                exercise.isCustom
            }
        )
        let exercises = try modelContext.fetch(descriptor)

        for exercise in exercises {
            modelContext.delete(exercise)
        }
    }
}

private enum AppLaunchPhase {
    case splash
    case ready
}

#Preview {
    AppLaunchView()
        .modelContainer(
            for: [
                Exercise.self,
                RoutineTemplate.self,
                RoutineTemplateExercise.self,
                RoutineTemplateSet.self,
                WorkoutSession.self,
                WorkoutSessionExercise.self,
                WorkoutSet.self,
            ],
            inMemory: true
        )
}
