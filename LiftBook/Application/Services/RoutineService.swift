//
//  RoutineService.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import Foundation
import SwiftData

struct RoutineService {
    @MainActor
    @discardableResult
    func create(
        from draft: RoutineDraft,
        in modelContext: ModelContext
    ) throws -> RoutineTemplate {
        let routine = RoutineTemplate(name: draft.trimmedName)
        modelContext.insert(routine)
        insertExercises(from: draft, into: routine, in: modelContext)
        try modelContext.save()
        return routine
    }

    @MainActor
    func update(
        _ routine: RoutineTemplate,
        with draft: RoutineDraft,
        in modelContext: ModelContext
    ) throws {
        routine.name = draft.trimmedName
        routine.updatedAt = .now

        for exercise in routine.exercises {
            modelContext.delete(exercise)
        }
        routine.exercises.removeAll()

        insertExercises(from: draft, into: routine, in: modelContext)
        try modelContext.save()
    }

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

    @MainActor
    private func insertExercises(
        from draft: RoutineDraft,
        into routine: RoutineTemplate,
        in modelContext: ModelContext
    ) {
        for (index, exercise) in draft.exercises.enumerated() {
            let routineExercise = RoutineTemplateExercise(
                exerciseID: exercise.exerciseID,
                exerciseName: exercise.exerciseName,
                sortOrder: index,
                targetSets: exercise.targetSets
            )

            modelContext.insert(routineExercise)
            routine.exercises.append(routineExercise)
        }
    }
}
