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
        trackWorkoutStarted(workout)
        return workout
    }

    @MainActor
    @discardableResult
    func createWorkout(
        from routine: RoutineTemplate,
        in modelContext: ModelContext
    ) throws -> WorkoutSession {
        try validateRoutineCanStartWorkout(routine)

        let workout = makeWorkout(from: routine, in: modelContext)
        try modelContext.save()
        trackWorkoutStarted(workout)
        return workout
    }

    @MainActor
    func delete(
        _ workout: WorkoutSession,
        in modelContext: ModelContext
    ) throws {
        modelContext.delete(workout)
        try modelContext.save()
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
        try Self.validateSetValues(reps: reps, weight: weight)

        set.reps = reps
        set.weight = set.isCompleted && Self.hasValidReps(reps) && weight == nil ? 0 : weight

        if !Self.hasValidReps(reps) {
            set.isCompleted = false
        }

        try modelContext.save()
    }

    @MainActor
    func toggleCompleted(
        _ set: WorkoutSet,
        in modelContext: ModelContext
    ) throws {
        if !set.isCompleted {
            guard Self.hasValidReps(set.reps) else {
                throw WorkoutServiceError.missingReps
            }

            try Self.validateWeight(set.weight)

            if set.weight == nil {
                set.weight = 0
            }
        }

        set.isCompleted.toggle()
        try modelContext.save()
    }

    @MainActor
    func setRestTimerDeadline(
        _ deadline: Date?,
        for workout: WorkoutSession,
        in modelContext: ModelContext
    ) throws {
        workout.restTimerDeadline = deadline
        try modelContext.save()
    }

    @MainActor
    @discardableResult
    func clearExpiredRestTimer(
        for workout: WorkoutSession,
        at date: Date = .now,
        in modelContext: ModelContext
    ) throws -> Bool {
        guard let restTimerDeadline = workout.restTimerDeadline,
              restTimerDeadline <= date else {
            return false
        }

        workout.restTimerDeadline = nil
        try modelContext.save()
        return true
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
    func hasCompletedSets(for workout: WorkoutSession) -> Bool {
        Self.hasValidCompletedSet(in: workout)
    }

    @MainActor
    func hasUncompletedFilledSets(for workout: WorkoutSession) -> Bool {
        workout.sortedExercises.contains { exercise in
            exercise.sortedSets.contains { set in
                !set.isCompleted && (set.reps != nil || set.weight != nil)
            }
        }
    }

    @MainActor
    func finish(
        _ workout: WorkoutSession,
        updateSourceRoutine shouldUpdateSourceRoutine: Bool,
        in modelContext: ModelContext
    ) throws {
        normalizeCompletedSetValues(in: workout)

        guard Self.hasValidCompletedSet(in: workout) else {
            throw WorkoutServiceError.noCompletedSets
        }

        if shouldUpdateSourceRoutine {
            try updateSourceRoutine(from: workout, in: modelContext)
        }

        workout.endedAt = .now
        workout.restTimerDeadline = nil
        try modelContext.save()
        trackWorkoutCompleted(workout, updatedSourceRoutine: shouldUpdateSourceRoutine)
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
    private func trackWorkoutStarted(_ workout: WorkoutSession) {
        AnalyticsTracker.track(
            .workoutStarted(
                source: analyticsSource(for: workout)
            )
        )
    }

    @MainActor
    private func trackWorkoutCompleted(
        _ workout: WorkoutSession,
        updatedSourceRoutine: Bool
    ) {
        AnalyticsTracker.track(
            .workoutCompleted(
                source: analyticsSource(for: workout),
                updatedSourceRoutine: updatedSourceRoutine
            )
        )
    }

    private func analyticsSource(for workout: WorkoutSession) -> AnalyticsWorkoutSource {
        workout.sourceRoutineTemplateID == nil ? .empty : .routine
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

            let workoutSets = workoutExercise.sortedSets

            if workoutSets.isEmpty {
                let routineSet = RoutineTemplateSet(sortOrder: 0)
                modelContext.insert(routineSet)
                routineExercise.sets.append(routineSet)
            } else {
                for (setIndex, workoutSet) in workoutSets.enumerated() {
                    let routineSet = RoutineTemplateSet(
                        sortOrder: setIndex,
                        reps: Self.hasValidReps(workoutSet.reps) ? workoutSet.reps : nil,
                        weight: Self.hasValidWeight(workoutSet.weight) ? workoutSet.weight : nil
                    )
                    modelContext.insert(routineSet)
                    routineExercise.sets.append(routineSet)
                }
            }
        }

        sourceRoutine.updatedAt = .now
    }

    private func validateRoutineCanStartWorkout(_ routine: RoutineTemplate) throws {
        guard !routine.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw WorkoutServiceError.missingWorkoutName
        }

        guard !routine.sortedExercises.isEmpty else {
            throw WorkoutServiceError.emptyRoutine
        }
    }

    private static func validateSetValues(reps: Int?, weight: Double?) throws {
        if let reps, !hasValidReps(reps) {
            throw WorkoutServiceError.invalidReps
        }

        try validateWeight(weight)
    }

    private static func validateWeight(_ weight: Double?) throws {
        guard let weight else {
            return
        }

        guard weight.isFinite, weight >= 0 else {
            throw WorkoutServiceError.invalidWeight
        }
    }

    private static func hasValidCompletedSet(in workout: WorkoutSession) -> Bool {
        workout.sortedExercises.contains { exercise in
            exercise.sortedSets.contains { set in
                set.isCompleted
                    && hasValidReps(set.reps)
                    && hasValidWeight(set.weight)
            }
        }
    }

    private static func hasValidWeight(_ weight: Double?) -> Bool {
        guard let weight else {
            return true
        }

        return weight.isFinite && weight >= 0
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

    private func normalizeCompletedSetValues(in workout: WorkoutSession) {
        for exercise in workout.sortedExercises {
            for set in exercise.sortedSets where set.isCompleted {
                if !Self.hasValidReps(set.reps) || !Self.hasValidWeight(set.weight) {
                    set.isCompleted = false
                    continue
                }

                if set.weight == nil {
                    set.weight = 0
                }
            }
        }
    }

    private static func hasValidReps(_ reps: Int?) -> Bool {
        guard let reps else {
            return false
        }

        return hasValidReps(reps)
    }

    private static func hasValidReps(_ reps: Int) -> Bool {
        reps > 0
    }
}

enum WorkoutServiceError: LocalizedError, Equatable {
    case missingWorkoutName
    case emptyRoutine
    case missingReps
    case invalidReps
    case invalidWeight
    case noCompletedSets

    var errorDescription: String? {
        switch self {
        case .missingWorkoutName:
            "Enter a workout name."
        case .emptyRoutine:
            "Add at least one exercise before starting this routine."
        case .missingReps:
            "Enter a number of reps before logging this set."
        case .invalidReps:
            "Reps must be blank or greater than 0."
        case .invalidWeight:
            "Weight must be blank or 0 or greater."
        case .noCompletedSets:
            "Log at least one set before finishing this workout."
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
