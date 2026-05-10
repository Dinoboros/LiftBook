//
//  RoutineTemplate.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftData

@Model
final class RoutineTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \RoutineTemplateExercise.routineTemplate)
    var exercises: [RoutineTemplateExercise] = []

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        exercises: [RoutineTemplateExercise] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.exercises = exercises
    }
}

@Model
final class RoutineTemplateExercise {
    @Attribute(.unique) var id: UUID
    var exerciseID: String
    var exerciseName: String
    var sortOrder: Int
    var targetSets: Int
    var routineTemplate: RoutineTemplate?

    @Relationship(deleteRule: .cascade, inverse: \RoutineTemplateSet.routineExercise)
    var sets: [RoutineTemplateSet] = []

    init(
        id: UUID = UUID(),
        exerciseID: String,
        exerciseName: String,
        sortOrder: Int,
        targetSets: Int = 2,
        routineTemplate: RoutineTemplate? = nil,
        sets: [RoutineTemplateSet] = []
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.sortOrder = sortOrder
        self.targetSets = targetSets
        self.routineTemplate = routineTemplate
        self.sets = sets
    }
}

@Model
final class RoutineTemplateSet {
    @Attribute(.unique) var id: UUID
    var sortOrder: Int
    var reps: Int?
    var weight: Double?
    var routineExercise: RoutineTemplateExercise?

    init(
        id: UUID = UUID(),
        sortOrder: Int,
        reps: Int? = nil,
        weight: Double? = nil,
        routineExercise: RoutineTemplateExercise? = nil
    ) {
        self.id = id
        self.sortOrder = sortOrder
        self.reps = reps
        self.weight = weight
        self.routineExercise = routineExercise
    }
}
