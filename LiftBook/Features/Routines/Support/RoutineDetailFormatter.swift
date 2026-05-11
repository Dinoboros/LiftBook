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
        guard let exercise = exerciseLibrary.first(where: { $0.id == routineExercise.exerciseID }) else {
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
