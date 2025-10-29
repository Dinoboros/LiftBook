//
//  Workout.swift
//  LiftBook
//
//  Created by Méryl VALIER on 01/10/2025.
//

import Foundation
import SwiftData

@Model
final class Workout {
    @Attribute(.unique) var id: UUID
    var name: String
    var startedAt: Date
    var completedAt: Date?
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout)
    var exercises: [WorkoutExercise]

    // Garder la compatibilité avec l'ancienne structure
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.workout)
    var exerciseSets: [ExerciseSet]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.exerciseSets = []
        self.exercises = []
        self.startedAt = Date()
        self.completedAt = nil
        self.notes = nil
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var duration: TimeInterval? {
        guard let completed = completedAt else { return nil }
        return completed.timeIntervalSince(startedAt)
    }

    // Anciennes propriétés gardées pour compatibilité (maintenant calculées via exercises)
    var legacyTotalSets: Int {
        exerciseSets.count
    }

    var legacyCompletedSets: Int {
        exerciseSets.filter { $0.isCompleted }.count
    }

    var legacyTotalVolume: Double {
        exerciseSets.reduce(0) { $0 + $1.volume }
    }
    
    func addSet(_ set: ExerciseSet) {
        exerciseSets.append(set)
    }
    
    func removeSet(_ set: ExerciseSet) {
        exerciseSets.removeAll { $0.id == set.id }
    }
    
    func complete(withNotes notes: String? = nil) {
        self.completedAt = Date()
        if let notes = notes {
            self.notes = notes
        }
    }

    // MARK: - Helper Methods for Exercise Management

    /// Ajoute un exercice au workout
    func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(exercise: exercise, order: exercises.count)
        exercises.append(workoutExercise)
    }

    /// Supprime un exercice du workout
    func removeExercise(_ workoutExercise: WorkoutExercise) {
        exercises.removeAll { $0.id == workoutExercise.id }
    }

    /// Ajoute un set à un exercice spécifique
    func addSet(_ set: ExerciseSet, to workoutExercise: WorkoutExercise) {
        set.workoutExercise = workoutExercise
        workoutExercise.addSet(set)
        exerciseSets.append(set) // Garder la compatibilité
    }

    /// Calcule le volume total du workout
    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }

    /// Nombre total de sets dans le workout
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.totalSets }
    }

    /// Nombre de sets complétés dans le workout
    var completedSets: Int {
        exercises.reduce(0) { $0 + $1.completedSets }
    }
}
