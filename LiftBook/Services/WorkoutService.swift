//
//  WorkoutService.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import Foundation
import SwiftData

struct WorkoutService {
    @MainActor
    @discardableResult
    func createEmptyWorkout(in modelContext: ModelContext) throws -> WorkoutSession {
        let workout = WorkoutSession()
        modelContext.insert(workout)
        try modelContext.save()
        return workout
    }

    @MainActor
    @discardableResult
    func createWorkout(
        from routine: RoutineTemplate,
        in modelContext: ModelContext
    ) throws -> WorkoutSession {
        let workout = makeWorkout(from: routine, in: modelContext)
        try modelContext.save()
        return workout
    }

    @MainActor
    func discard(
        _ workouts: [WorkoutSession],
        in modelContext: ModelContext
    ) throws {
        for workout in workouts {
            modelContext.delete(workout)
        }

        try modelContext.save()
    }

    @MainActor
    func addExercises(
        _ exercises: [Exercise],
        to workout: WorkoutSession,
        defaultSetCount: Int = 2,
        in modelContext: ModelContext
    ) throws {
        let existingExerciseIDs = Set(workout.exercises.map(\.exerciseID))
        let firstSortOrder = (workout.exercises.map(\.sortOrder).max() ?? -1) + 1
        let newExercises = exercises.filter { !existingExerciseIDs.contains($0.id) }

        for (index, exercise) in newExercises.enumerated() {
            let workoutExercise = WorkoutSessionExercise(
                exerciseID: exercise.id,
                exerciseName: exercise.name,
                sortOrder: firstSortOrder + index
            )
            modelContext.insert(workoutExercise)
            workout.exercises.append(workoutExercise)

            for setIndex in 0..<max(defaultSetCount, 1) {
                let workoutSet = WorkoutSet(sortOrder: setIndex)
                modelContext.insert(workoutSet)
                workoutExercise.sets.append(workoutSet)
            }
        }

        try modelContext.save()
    }

    @MainActor
    func deleteExercise(
        _ exercise: WorkoutSessionExercise,
        from workout: WorkoutSession,
        in modelContext: ModelContext
    ) throws {
        workout.exercises.removeAll { $0.id == exercise.id }
        modelContext.delete(exercise)
        normalizeExerciseSortOrders(for: workout)
        try modelContext.save()
    }

    @MainActor
    @discardableResult
    func addSet(
        to exercise: WorkoutSessionExercise,
        in modelContext: ModelContext
    ) throws -> WorkoutSet {
        let nextSortOrder = (exercise.sets.map(\.sortOrder).max() ?? -1) + 1
        let workoutSet = WorkoutSet(sortOrder: nextSortOrder)
        modelContext.insert(workoutSet)
        exercise.sets.append(workoutSet)
        try modelContext.save()
        return workoutSet
    }

    @MainActor
    func deleteSet(
        _ set: WorkoutSet,
        from exercise: WorkoutSessionExercise,
        in modelContext: ModelContext
    ) throws {
        guard exercise.sets.count > 1 else {
            return
        }

        exercise.sets.removeAll { $0.id == set.id }
        modelContext.delete(set)
        normalizeSetSortOrders(for: exercise)
        try modelContext.save()
    }

    @MainActor
    func updateSet(
        _ set: WorkoutSet,
        reps: Int?,
        weight: Double?,
        in modelContext: ModelContext
    ) throws {
        set.reps = reps
        set.weight = weight
        try modelContext.save()
    }

    @MainActor
    func toggleCompleted(
        _ set: WorkoutSet,
        in modelContext: ModelContext
    ) throws {
        set.isCompleted.toggle()
        try modelContext.save()
    }

    @MainActor
    func sourceRoutine(
        for workout: WorkoutSession,
        in modelContext: ModelContext
    ) throws -> RoutineTemplate? {
        guard let sourceRoutineTemplateID = workout.sourceRoutineTemplateID else {
            return nil
        }

        var descriptor = FetchDescriptor<RoutineTemplate>(
            predicate: #Predicate<RoutineTemplate> { routine in
                routine.id == sourceRoutineTemplateID
            }
        )
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first
    }

    @MainActor
    func hasSourceRoutineStructureChanges(
        for workout: WorkoutSession,
        sourceRoutine: RoutineTemplate?
    ) -> Bool {
        guard let sourceRoutine else {
            return false
        }

        return workout.structureItems != sourceRoutine.structureItems
    }

    @MainActor
    func finish(
        _ workout: WorkoutSession,
        updateSourceRoutine shouldUpdateSourceRoutine: Bool,
        in modelContext: ModelContext
    ) throws {
        if shouldUpdateSourceRoutine {
            try updateSourceRoutine(from: workout, in: modelContext)
        }

        workout.endedAt = .now
        try modelContext.save()
    }

    @MainActor
    func save(in modelContext: ModelContext) throws {
        try modelContext.save()
    }

    @MainActor
    private func makeWorkout(
        from routine: RoutineTemplate,
        in modelContext: ModelContext
    ) -> WorkoutSession {
        let workout = WorkoutSession(
            name: routine.name,
            sourceRoutineTemplateID: routine.id
        )
        modelContext.insert(workout)

        for (exerciseIndex, exercise) in routine.sortedExercises.enumerated() {
            let workoutExercise = WorkoutSessionExercise(
                exerciseID: exercise.exerciseID,
                exerciseName: exercise.exerciseName,
                sortOrder: exerciseIndex
            )
            modelContext.insert(workoutExercise)
            workout.exercises.append(workoutExercise)

            let templateSets = exercise.sortedSets
            let targetSetCount = exercise.targetSetCount

            for setIndex in 0..<targetSetCount {
                let templateSet = templateSets[safe: setIndex]
                let workoutSet = WorkoutSet(
                    sortOrder: setIndex,
                    reps: templateSet?.reps,
                    weight: templateSet?.weight
                )
                modelContext.insert(workoutSet)
                workoutExercise.sets.append(workoutSet)
            }
        }

        return workout
    }

    @MainActor
    private func updateSourceRoutine(
        from workout: WorkoutSession,
        in modelContext: ModelContext
    ) throws {
        guard let sourceRoutine = try sourceRoutine(for: workout, in: modelContext) else {
            return
        }

        for exercise in sourceRoutine.exercises {
            modelContext.delete(exercise)
        }
        sourceRoutine.exercises.removeAll()

        for (index, workoutExercise) in workout.sortedExercises.enumerated() {
            let routineExercise = RoutineTemplateExercise(
                exerciseID: workoutExercise.exerciseID,
                exerciseName: workoutExercise.exerciseName,
                sortOrder: index,
                targetSets: max(workoutExercise.sets.count, 1)
            )
            modelContext.insert(routineExercise)
            sourceRoutine.exercises.append(routineExercise)

            for (setIndex, workoutSet) in workoutExercise.sortedSets.enumerated() {
                let routineSet = RoutineTemplateSet(
                    sortOrder: setIndex,
                    reps: workoutSet.reps,
                    weight: workoutSet.weight
                )
                modelContext.insert(routineSet)
                routineExercise.sets.append(routineSet)
            }
        }

        sourceRoutine.updatedAt = .now
    }

    @MainActor
    private func normalizeExerciseSortOrders(for workout: WorkoutSession) {
        for (index, exercise) in workout.sortedExercises.enumerated() {
            exercise.sortOrder = index
        }
    }

    @MainActor
    private func normalizeSetSortOrders(for exercise: WorkoutSessionExercise) {
        for (index, set) in exercise.sortedSets.enumerated() {
            set.sortOrder = index
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
