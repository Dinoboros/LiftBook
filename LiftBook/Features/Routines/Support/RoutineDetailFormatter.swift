//
//  RoutineDetailFormatter.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

enum RoutineDetailFormatter {
    static func routineSummaryText(for routine: RoutineTemplate) -> String {
        "\(exerciseCountText(for: routine)) · \(setCountText(for: routine))"
    }

    static func exerciseSubtitle(
        for routineExercise: RoutineTemplateExercise,
        in exerciseLibrary: [Exercise]
    ) -> String? {
        exerciseSubtitle(
            forExerciseID: routineExercise.exerciseID,
            in: exerciseLibraryByID(from: exerciseLibrary)
        )
    }

    static func exerciseSubtitle(
        for routineExercise: RoutineTemplateExercise,
        in exerciseLibraryByID: [String: Exercise]
    ) -> String? {
        exerciseSubtitle(forExerciseID: routineExercise.exerciseID, in: exerciseLibraryByID)
    }

    static func exerciseSubtitle(
        for workoutExercise: WorkoutSessionExercise,
        in exerciseLibrary: [Exercise]
    ) -> String? {
        exerciseSubtitle(
            forExerciseID: workoutExercise.exerciseID,
            in: exerciseLibraryByID(from: exerciseLibrary)
        )
    }

    static func exerciseSubtitle(
        for workoutExercise: WorkoutSessionExercise,
        in exerciseLibraryByID: [String: Exercise]
    ) -> String? {
        exerciseSubtitle(forExerciseID: workoutExercise.exerciseID, in: exerciseLibraryByID)
    }

    private static func exerciseSubtitle(
        forExerciseID exerciseID: String,
        in exerciseLibraryByID: [String: Exercise]
    ) -> String? {
        guard let exercise = exerciseLibraryByID[exerciseID] else {
            return nil
        }

        var parts: [String] = []

        if !exercise.primaryMuscles.isEmpty {
            parts.append(exercise.primaryMuscles.joined(separator: ", ").capitalized)
        } else if !exercise.category.isEmpty {
            parts.append(exercise.category.capitalized)
        }

        if let equipment = exercise.equipment.first(where: { !$0.isEmpty }) {
            parts.append(equipment.capitalized)
        }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private static func exerciseLibraryByID(from exerciseLibrary: [Exercise]) -> [String: Exercise] {
        Dictionary(uniqueKeysWithValues: exerciseLibrary.map { ($0.id, $0) })
    }

    private static func exerciseCountText(for routine: RoutineTemplate) -> String {
        let count = routine.exercises.count

        if count == 1 {
            return "1 exercise"
        }

        return "\(count) exercises"
    }

    private static func setCountText(for routine: RoutineTemplate) -> String {
        let count = routine.sortedExercises.reduce(0) { partialResult, exercise in
            partialResult + exercise.targetSetCount
        }

        if count == 1 {
            return "1 set"
        }

        return "\(count) sets"
    }
}
