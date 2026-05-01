//
//  RoutineService.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import SwiftData

struct RoutineService {
    @MainActor
    @discardableResult
    func duplicate(
        _ routine: RoutineTemplate,
        in modelContext: ModelContext
    ) throws -> RoutineTemplate {
        let duplicatedRoutine = RoutineTemplate(name: "\(routine.name) Copy")
        modelContext.insert(duplicatedRoutine)

        for (index, exercise) in routine.sortedExercises.enumerated() {
            let duplicatedExercise = RoutineTemplateExercise(
                exerciseID: exercise.exerciseID,
                exerciseName: exercise.exerciseName,
                sortOrder: index,
                targetSets: exercise.targetSets
            )
            modelContext.insert(duplicatedExercise)
            duplicatedRoutine.exercises.append(duplicatedExercise)
        }

        try modelContext.save()
        return duplicatedRoutine
    }

    @MainActor
    func delete(
        _ routine: RoutineTemplate,
        in modelContext: ModelContext
    ) throws {
        modelContext.delete(routine)
        try modelContext.save()
    }
}
