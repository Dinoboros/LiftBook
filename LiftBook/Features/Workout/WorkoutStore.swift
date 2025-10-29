//
//  WorkoutStore.swift
//  LiftBook
//
//  Created by Méryl VALIER on 27/10/2025.
//

import Foundation
import SwiftData

@Observable
final class WorkoutStore {
    private let modelContext: ModelContext
    
    // Refresh trigger that views can observe
    var refreshTrigger: Int = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    private func notifyRefresh() {
        refreshTrigger += 1
    }
    
    // MARK: CRUD Methods
    func getWorkouts() throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\.startedAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func getWorkout(by id: UUID) throws -> Workout? {
        nil
    }
    
    func add(_ workout: Workout) throws {
        do {
            modelContext.insert(workout)
            try modelContext.save()
            notifyRefresh()
        } catch {
            throw error
        }
    }
    
    func update(_ workout: Workout) throws {
        do {
            try modelContext.save()
            notifyRefresh()
        } catch {
            throw error
        }
    }
    
    func delete(_ workout: Workout) throws {
        do {
            modelContext.delete(workout)
            try modelContext.save()
            notifyRefresh()
        } catch {
            throw error
        }
    }
    
    // MARK: Exercise in workout methods
    func addExerciseToWorkout(exercise: Exercise, to workout: Workout, at index: Int) throws -> WorkoutExercise {
        WorkoutExercise(exercise: exercise, order: index)
    }
    
    func removeExerciseFromWorkout(exercise: Exercise, from workout: Workout) throws {

    }
    
    // MARK: Sets methods
    func addSetToWorkoutExercise(set: ExerciseSet, to workoutExercise: WorkoutExercise) throws {
        
    }
    
    func removeSetFromWorkoutExercise(set: ExerciseSet, from workoutExercise: WorkoutExercise) throws {
        
    }
    
    // MARK: Sessions methods
    func startSession(_ workout: Workout) throws {
        
    }
    
    func completeWorkout(_ workout: Workout) throws {
        
    }
    
    
    // MARK: Home methods
    func getRecentWorkouts(limit: Int) throws -> [Workout] {
        []
    }
}
