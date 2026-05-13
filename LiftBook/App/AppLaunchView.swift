//
//  AppLaunchView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import Foundation
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

    private var shouldSeedHomeCardsForUITesting: Bool {
        processArguments.contains("-uiTestingSeedHomeCards")
    }

    private var isRunningUITests: Bool {
        shouldSkipSplashForUITesting
            || shouldSkipOnboardingForUITesting
            || shouldResetDataForUITesting
            || shouldSeedHomeCardsForUITesting
    }

    private var processArguments: [String] {
        ProcessInfo.processInfo.arguments
    }

    @MainActor
    private func prepareUITestDataIfNeeded() {
        guard (shouldResetDataForUITesting || shouldSeedHomeCardsForUITesting),
              !hasPreparedUITestData else {
            return
        }

        hasPreparedUITestData = true

        do {
            if shouldResetDataForUITesting {
                try deleteAll(WorkoutSession.self)
                try deleteAll(RoutineTemplate.self)
                try deleteCustomExercises()
            }

            if shouldSeedHomeCardsForUITesting {
                seedHomeCardsForUITesting()
            }

            try modelContext.save()
        } catch {
            assertionFailure("Could not prepare UI test data: \(error)")
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

    @MainActor
    private func seedHomeCardsForUITesting() {
        let routine = RoutineTemplate(
            name: "Home Card Routine",
            createdAt: Date(timeIntervalSince1970: 1_767_225_600),
            updatedAt: Date(timeIntervalSince1970: 1_767_225_600)
        )
        modelContext.insert(routine)

        let routineExercise = RoutineTemplateExercise(
            exerciseID: "barbell-bench-press",
            exerciseName: "Barbell Bench Press",
            sortOrder: 0,
            targetSets: 2
        )
        modelContext.insert(routineExercise)
        routine.exercises.append(routineExercise)

        for index in 0..<2 {
            let set = RoutineTemplateSet(sortOrder: index, reps: 8, weight: 80)
            modelContext.insert(set)
            routineExercise.sets.append(set)
        }

        let startedAt = Date(timeIntervalSince1970: 1_767_229_200)
        let endedAt = Date(timeIntervalSince1970: 1_767_232_800)
        let workout = WorkoutSession(
            name: "Home Card History",
            startedAt: startedAt,
            endedAt: endedAt,
            sourceRoutineTemplateID: routine.id
        )
        modelContext.insert(workout)

        let workoutExercise = WorkoutSessionExercise(
            exerciseID: "barbell-bench-press",
            exerciseName: "Barbell Bench Press",
            sortOrder: 0
        )
        modelContext.insert(workoutExercise)
        workout.exercises.append(workoutExercise)

        for index in 0..<2 {
            let set = WorkoutSet(sortOrder: index, reps: 8, weight: 80, isCompleted: true)
            modelContext.insert(set)
            workoutExercise.sets.append(set)
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
