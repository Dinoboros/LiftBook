//
//  LiftBookPersistence.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import SwiftData

enum LiftBookPersistence {
    static var schema: Schema {
        Schema([
            Exercise.self,
            RoutineTemplate.self,
            RoutineTemplateExercise.self,
            RoutineTemplateSet.self,
            WorkoutSession.self,
            WorkoutSessionExercise.self,
            WorkoutSet.self,
        ])
    }

    static func makeModelContainer(isStoredInMemoryOnly: Bool = false) throws -> ModelContainer {
        let schema = Self.schema
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: isStoredInMemoryOnly
        )

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }
}
