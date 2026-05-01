//
//  PersistenceModelExtensions.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

struct WorkoutStructureItem: Equatable {
    let exerciseID: String
    let setCount: Int
}

extension RoutineTemplate {
    var sortedExercises: [RoutineTemplateExercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    var structureItems: [WorkoutStructureItem] {
        sortedExercises.map {
            WorkoutStructureItem(
                exerciseID: $0.exerciseID,
                setCount: max($0.targetSets, 1)
            )
        }
    }
}

extension WorkoutSession {
    var sortedExercises: [WorkoutSessionExercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    var structureItems: [WorkoutStructureItem] {
        sortedExercises.map {
            WorkoutStructureItem(
                exerciseID: $0.exerciseID,
                setCount: max($0.sets.count, 1)
            )
        }
    }
}

extension WorkoutSessionExercise {
    var sortedSets: [WorkoutSet] {
        sets.sorted { $0.sortOrder < $1.sortOrder }
    }
}
