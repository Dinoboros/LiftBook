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
        weightUnit: WeightUnit = .kilograms,
        in modelContext: ModelContext
    ) throws -> RoutineTemplate {
        try validate(draft, weightUnit: weightUnit)

        let routine = RoutineTemplate(name: draft.trimmedName)
        modelContext.insert(routine)
        insertExercises(from: draft, weightUnit: weightUnit, into: routine, in: modelContext)
        try modelContext.save()
        return routine
    }

    @MainActor
    func update(
        _ routine: RoutineTemplate,
        with draft: RoutineDraft,
        weightUnit: WeightUnit = .kilograms,
        in modelContext: ModelContext
    ) throws {
        try validate(draft, weightUnit: weightUnit)

        routine.name = draft.trimmedName
        routine.updatedAt = .now

        for exercise in routine.exercises {
            modelContext.delete(exercise)
        }
        routine.exercises.removeAll()

        insertExercises(from: draft, weightUnit: weightUnit, into: routine, in: modelContext)
        try modelContext.save()
    }

    @MainActor
    @discardableResult
    func duplicate(
        _ routine: RoutineTemplate,
        in modelContext: ModelContext
    ) throws -> RoutineTemplate {
        guard !routine.sortedExercises.isEmpty else {
            throw RoutineServiceError.missingExercises
        }

        let duplicatedRoutine = RoutineTemplate(name: "\(routine.name) Copy")
        modelContext.insert(duplicatedRoutine)

        for (index, exercise) in routine.sortedExercises.enumerated() {
            let duplicatedExercise = RoutineTemplateExercise(
                exerciseID: exercise.exerciseID,
                exerciseName: exercise.exerciseName,
                sortOrder: index,
                targetSets: exercise.targetSetCount
            )
            modelContext.insert(duplicatedExercise)
            duplicatedRoutine.exercises.append(duplicatedExercise)

            insertSets(
                from: exercise.sortedSets,
                into: duplicatedExercise,
                fallbackSetCount: exercise.targetSetCount,
                in: modelContext
            )
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
        weightUnit: WeightUnit,
        into routine: RoutineTemplate,
        in modelContext: ModelContext
    ) {
        for (index, exercise) in draft.exercises.enumerated() {
            let routineExercise = RoutineTemplateExercise(
                exerciseID: exercise.exerciseID,
                exerciseName: exercise.exerciseName,
                sortOrder: index,
                targetSets: max(exercise.targetSets, 1)
            )

            modelContext.insert(routineExercise)
            routine.exercises.append(routineExercise)
            insertSets(
                from: exercise.sets,
                weightUnit: weightUnit,
                into: routineExercise,
                in: modelContext
            )
        }
    }

    @MainActor
    private func insertSets(
        from draftSets: [RoutineSetDraft],
        weightUnit: WeightUnit,
        into routineExercise: RoutineTemplateExercise,
        in modelContext: ModelContext
    ) {
        for (index, set) in draftSets.enumerated() {
            let routineSet = RoutineTemplateSet(
                sortOrder: index,
                reps: set.repsValue,
                weight: set.weightValue(unit: weightUnit)
            )
            modelContext.insert(routineSet)
            routineExercise.sets.append(routineSet)
        }
    }

    @MainActor
    private func insertSets(
        from sourceSets: [RoutineTemplateSet],
        into routineExercise: RoutineTemplateExercise,
        fallbackSetCount: Int,
        in modelContext: ModelContext
    ) {
        if sourceSets.isEmpty {
            for index in 0..<max(fallbackSetCount, 1) {
                let routineSet = RoutineTemplateSet(sortOrder: index)
                modelContext.insert(routineSet)
                routineExercise.sets.append(routineSet)
            }
        } else {
            for (index, sourceSet) in sourceSets.enumerated() {
                let routineSet = RoutineTemplateSet(
                    sortOrder: index,
                    reps: sourceSet.reps,
                    weight: sourceSet.weight
                )
                modelContext.insert(routineSet)
                routineExercise.sets.append(routineSet)
            }
        }
    }

    private func validate(_ draft: RoutineDraft, weightUnit: WeightUnit) throws {
        guard !draft.trimmedName.isEmpty else {
            throw RoutineServiceError.missingName
        }

        guard !draft.exercises.isEmpty else {
            throw RoutineServiceError.missingExercises
        }

        for exercise in draft.exercises {
            guard !exercise.sets.isEmpty else {
                throw RoutineServiceError.missingSets
            }

            for set in exercise.sets {
                guard set.hasValidReps else {
                    throw RoutineServiceError.invalidReps
                }

                guard set.hasValidWeight(unit: weightUnit) else {
                    throw RoutineServiceError.invalidWeight
                }
            }
        }
    }
}

enum RoutineServiceError: LocalizedError, Equatable {
    case missingName
    case missingExercises
    case missingSets
    case invalidReps
    case invalidWeight

    var errorDescription: String? {
        switch self {
        case .missingName:
            "Enter a routine name."
        case .missingExercises:
            "Add at least one exercise to the routine."
        case .missingSets:
            "Every exercise needs at least one set."
        case .invalidReps:
            "Reps must be blank or greater than 0."
        case .invalidWeight:
            "Weight must be blank or 0 or greater."
        }
    }
}
