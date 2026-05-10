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

    init(exercise: RoutineTemplateExercise) {
        id = exercise.id
        exerciseID = exercise.exerciseID
        exerciseName = exercise.exerciseName
        category = ""
        primaryMuscles = []
        let sortedSets = exercise.sortedSets

        if sortedSets.isEmpty {
            sets = (0..<max(exercise.targetSets, 1)).map { _ in RoutineSetDraft() }
        } else {
            sets = sortedSets.map { RoutineSetDraft(set: $0) }
        }
    }

    private static func defaultSets() -> [RoutineSetDraft] {
        [
            RoutineSetDraft(),
            RoutineSetDraft()
        ]
    }
}

struct RoutineSetDraft: Identifiable, Equatable {
    let id = UUID()
    var reps = ""
    var weight = ""

    var repsValue: Int? {
        let trimmedValue = reps.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : Int(trimmedValue)
    }

    var weightValue: Double? {
        let trimmedValue = weight
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !trimmedValue.isEmpty, let weight = Double(trimmedValue), weight.isFinite else {
            return nil
        }

        return weight
    }

    init() {}

    init(set: RoutineTemplateSet) {
        reps = Self.text(for: set.reps)
        weight = Self.text(for: set.weight)
    }

    private static func text(for reps: Int?) -> String {
        guard let reps else {
            return ""
        }

        return String(reps)
    }

    private static func text(for weight: Double?) -> String {
        guard let weight else {
            return ""
        }

        if weight.rounded() == weight {
            return String(Int(weight))
        }

        return String(weight)
    }
}
