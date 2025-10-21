//
//  WorkoutExercise.swift
//  LiftBook
//
//  Created by LiftBook Team on 21/10/2025.
//

import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    @Attribute(.unique) var id: UUID
    var order: Int // Pour garder l'ordre des exercices dans le workout

    @Relationship var workout: Workout?
    @Relationship var exercise: Exercise?
    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.workoutExercise)
    var sets: [ExerciseSet]

    init(exercise: Exercise, order: Int) {
        self.id = UUID()
        self.exercise = exercise
        self.order = order
        self.sets = []
    }

    /// Calcule le volume total pour cet exercice (somme de tous ses sets)
    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }

    /// Nombre total de sets pour cet exercice
    var totalSets: Int {
        sets.count
    }

    /// Nombre de sets complétés pour cet exercice
    var completedSets: Int {
        sets.filter { $0.isCompleted }.count
    }

    /// Ajoute un nouveau set à cet exercice
    func addSet(_ set: ExerciseSet) {
        sets.append(set)
    }

    /// Supprime un set de cet exercice
    func removeSet(_ set: ExerciseSet) {
        sets.removeAll { $0.id == set.id }
    }
}
