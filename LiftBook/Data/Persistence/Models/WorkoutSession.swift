//
//  WorkoutSession.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var name: String
    var startedAt: Date
    var endedAt: Date?
    var sourceRoutineTemplateID: UUID?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSessionExercise.workoutSession)
    var exercises: [WorkoutSessionExercise] = []

    var isFinished: Bool {
        endedAt != nil
    }

    init(
        id: UUID = UUID(),
        name: String = "Empty Workout",
        startedAt: Date = .now,
        endedAt: Date? = nil,
        sourceRoutineTemplateID: UUID? = nil,
        exercises: [WorkoutSessionExercise] = []
    ) {
        self.id = id
        self.name = name
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.sourceRoutineTemplateID = sourceRoutineTemplateID
        self.exercises = exercises
    }
}

@Model
final class WorkoutSessionExercise {
    @Attribute(.unique) var id: UUID
    var exerciseID: String
    var exerciseName: String
    var sortOrder: Int
    var workoutSession: WorkoutSession?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workoutExercise)
    var sets: [WorkoutSet] = []

    init(
        id: UUID = UUID(),
        exerciseID: String,
        exerciseName: String,
        sortOrder: Int,
        workoutSession: WorkoutSession? = nil,
        sets: [WorkoutSet] = []
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.sortOrder = sortOrder
        self.workoutSession = workoutSession
        self.sets = sets
    }
}

@Model
final class WorkoutSet {
    @Attribute(.unique) var id: UUID
    var sortOrder: Int
    var reps: Int?
    var weight: Double?
    var isCompleted: Bool
    var workoutExercise: WorkoutSessionExercise?

    init(
        id: UUID = UUID(),
        sortOrder: Int,
        reps: Int? = nil,
        weight: Double? = nil,
        isCompleted: Bool = false,
        workoutExercise: WorkoutSessionExercise? = nil
    ) {
        self.id = id
        self.sortOrder = sortOrder
        self.reps = reps
        self.weight = weight
        self.isCompleted = isCompleted
        self.workoutExercise = workoutExercise
    }
}
