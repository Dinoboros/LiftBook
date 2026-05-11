//
//  RoutineDraft.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import Foundation

struct RoutineDraft: Equatable {
    var name = ""
    var exercises: [RoutineExerciseDraft] = []

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedName.isEmpty && !exercises.isEmpty
    }

    var exerciseIDs: Set<String> {
        Set(exercises.map(\.exerciseID))
    }

    init() {}

    @MainActor
    init(routine: RoutineTemplate) {
        name = routine.name
        exercises = routine.sortedExercises.map(RoutineExerciseDraft.init)
    }

    @MainActor
    mutating func addExercises(_ exercises: [Exercise]) {
        let newDrafts = exercises
            .filter { !exerciseIDs.contains($0.id) }
            .map(RoutineExerciseDraft.init)

        self.exercises.append(contentsOf: newDrafts)
    }

    mutating func deleteExercise(_ exercise: RoutineExerciseDraft) {
        exercises.removeAll { $0.id == exercise.id }
    }
}
