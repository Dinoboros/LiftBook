//
//  AppDebugAction.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

#if DEBUG
import SwiftUI

enum AppDebugAction {
    case reloadExerciseLibrary
    case clearWorkoutData
    case freshInstallReset

    var title: String {
        switch self {
        case .reloadExerciseLibrary:
            "Reload Exercise Library?"
        case .clearWorkoutData:
            "Clear Workout Data?"
        case .freshInstallReset:
            "Start Over?"
        }
    }

    var confirmationButtonTitle: String {
        switch self {
        case .reloadExerciseLibrary:
            "Reload Exercises"
        case .clearWorkoutData:
            "Clear Workouts and Routines"
        case .freshInstallReset:
            "Delete App Data"
        }
    }

    var confirmationMessage: String {
        switch self {
        case .reloadExerciseLibrary:
            "This deletes the current exercise library and imports the bundled default seed again."
        case .clearWorkoutData:
            "This deletes workouts and routines but keeps onboarding and the exercise library."
        case .freshInstallReset:
            "This clears local LiftBook data and returns the app to onboarding."
        }
    }

    var buttonRole: ButtonRole? {
        switch self {
        case .reloadExerciseLibrary:
            nil
        case .clearWorkoutData, .freshInstallReset:
            .destructive
        }
    }
}
#endif
