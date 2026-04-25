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

    init(
        id: UUID = UUID(),
        exerciseID: String,
        exerciseName: String,
        sortOrder: Int,
        targetSets: Int = 3,
        routineTemplate: RoutineTemplate? = nil
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
        self.sortOrder = sortOrder
        self.targetSets = targetSets
        self.routineTemplate = routineTemplate
    }
}
