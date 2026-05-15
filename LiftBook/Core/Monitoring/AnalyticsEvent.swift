//
//  AnalyticsEvent.swift
//  LiftBook
//
//  Created by Codex on 15/05/2026.
//

enum AnalyticsWorkoutSource: String {
    case empty
    case routine
}

enum AnalyticsEvent {
    case onboardingCompleted
    case customExerciseCreated
    case routineCreated
    case workoutStarted(source: AnalyticsWorkoutSource)
    case workoutCompleted(
        source: AnalyticsWorkoutSource,
        updatedSourceRoutine: Bool
    )

    var name: String {
        switch self {
        case .onboardingCompleted:
            "onboarding.completed"
        case .customExerciseCreated:
            "exercise.custom_created"
        case .routineCreated:
            "routine.created"
        case .workoutStarted:
            "workout.started"
        case .workoutCompleted:
            "workout.completed"
        }
    }

    var parameters: [String: String] {
        switch self {
        case .onboardingCompleted, .customExerciseCreated:
            [:]
        case .routineCreated:
            [:]
        case .workoutStarted(let source):
            [
                "source": source.rawValue
            ]
        case .workoutCompleted(
            let source,
            let updatedSourceRoutine
        ):
            [
                "source": source.rawValue,
                "updatedSourceRoutine": String(updatedSourceRoutine)
            ]
        }
    }
}
