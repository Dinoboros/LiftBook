//
//  RoutineExerciseDraft.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

struct RoutineExerciseDraft: Identifiable, Equatable {
    let id: UUID
    let exerciseID: String
    let exerciseName: String
    let category: String
    let primaryMuscles: [String]
    var sets: [RoutineSetDraft]

    var targetSets: Int {
        sets.count
    }

    func canSave(weightUnit: WeightUnit) -> Bool {
        !sets.isEmpty && sets.allSatisfy { $0.hasValidValues(unit: weightUnit) }
    }

    var subtitle: String {
        if !primaryMuscles.isEmpty {
            return primaryMuscles.joined(separator: ", ").capitalized
        }

        return category.capitalized
    }

    init(exercise: Exercise) {
        id = UUID()
        exerciseID = exercise.id
        exerciseName = exercise.name
        category = exercise.category
        primaryMuscles = exercise.primaryMuscles
        sets = Self.defaultSets()
    }

    init(exercise: RoutineTemplateExercise, weightUnit: WeightUnit = .kilograms) {
        id = exercise.id
        exerciseID = exercise.exerciseID
        exerciseName = exercise.exerciseName
        category = ""
        primaryMuscles = []
        let sortedSets = exercise.sortedSets

        if sortedSets.isEmpty {
            sets = (0..<max(exercise.targetSets, 1)).map { _ in RoutineSetDraft() }
        } else {
            sets = sortedSets.map { RoutineSetDraft(set: $0, weightUnit: weightUnit) }
        }
    }

    private static func defaultSets() -> [RoutineSetDraft] {
        [
            RoutineSetDraft(),
            RoutineSetDraft()
        ]
    }
}
