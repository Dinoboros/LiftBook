//
//  HomeWorkoutFormatter.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

enum HomeWorkoutFormatter {
    static func exerciseSummary(for routine: RoutineTemplate) -> String {
        exerciseSummary(from: routine.sortedExercises.map(\.exerciseName))
    }

    static func exerciseSummary(for workout: WorkoutSession) -> String {
        exerciseSummary(from: workout.sortedExercises.map(\.exerciseName))
    }

    static func completedAtText(for workout: WorkoutSession) -> String {
        guard let endedAt = workout.endedAt else {
            return "Date unavailable"
        }

        return endedAt.formatted(date: .abbreviated, time: .shortened)
    }

    private static func exerciseSummary(from exerciseNames: [String]) -> String {
        let previewExerciseNames = exerciseNames.prefix(3)

        guard !previewExerciseNames.isEmpty else {
            return "No exercises"
        }

        return previewExerciseNames.joined(separator: ", ")
    }
}
