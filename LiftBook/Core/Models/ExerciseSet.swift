//
//  ExerciseSet.swift
//  LiftBook
//
//  Created by Méryl VALIER on 01/10/2025.
//

import Foundation
import SwiftData

@Model
final class ExerciseSet {
    @Attribute(.unique) var id: UUID
    var reps: Int
    var weight: Double
    var rest: Int
    var completedAt: Date?
    var notes: String?

    @Relationship var exercise: Exercise?
    @Relationship var workout: Workout?
    @Relationship var workoutExercise: WorkoutExercise?

    init(exercise: Exercise, reps: Int, weight: Double, rest: Int) {
        self.id = UUID()
        self.exercise = exercise
        self.reps = reps
        self.weight = weight
        self.rest = rest
        self.completedAt = nil
        self.notes = nil
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var volume: Double {
        Double(reps) * weight
    }
}
