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
    case routineCreated(exerciseCount: Int, setCount: Int)
    case workoutStarted(source: AnalyticsWorkoutSource, exerciseCount: Int, setCount: Int)
    case workoutCompleted(
        source: AnalyticsWorkoutSource,
        exerciseCount: Int,
        completedSetCount: Int,
        durationSeconds: Int,
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
        case .routineCreated(let exerciseCount, let setCount):
            [
                "exerciseCount": String(exerciseCount),
                "setCount": String(setCount)
            ]
        case .workoutStarted(let source, let exerciseCount, let setCount):
            [
                "source": source.rawValue,
                "exerciseCount": String(exerciseCount),
                "setCount": String(setCount)
            ]
        case .workoutCompleted(
            let source,
            let exerciseCount,
            let completedSetCount,
            let durationSeconds,
            let updatedSourceRoutine
        ):
            [
                "source": source.rawValue,
                "exerciseCount": String(exerciseCount),
                "completedSetCount": String(completedSetCount),
                "durationSeconds": String(durationSeconds),
                "updatedSourceRoutine": String(updatedSourceRoutine)
            ]
        }
    }
}
