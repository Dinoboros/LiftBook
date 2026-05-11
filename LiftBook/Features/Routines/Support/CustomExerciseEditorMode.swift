//
//  CustomExerciseEditorMode.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

struct CustomExerciseEditorMode: Identifiable {
    let id: String
    let exercise: Exercise?

    static func create() -> CustomExerciseEditorMode {
        CustomExerciseEditorMode(id: "create-\(UUID().uuidString)", exercise: nil)
    }

    static func edit(_ exercise: Exercise) -> CustomExerciseEditorMode {
        CustomExerciseEditorMode(id: "edit-\(exercise.id)", exercise: exercise)
    }

    var title: String {
        exercise == nil ? "New Exercise" : "Edit Exercise"
    }

    var saveTitle: String {
        exercise == nil ? "Create" : "Done"
    }

    var initialDraft: ExerciseDraft {
        guard let exercise else {
            return ExerciseDraft()
        }

        return ExerciseDraft(exercise: exercise)
    }
}
