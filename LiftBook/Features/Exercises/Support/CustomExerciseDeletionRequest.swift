//
//  CustomExerciseDeletionRequest.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

struct CustomExerciseDeletionRequest {
    let exerciseID: String
    let exerciseName: String
    let isUsedInRoutines: Bool

    var confirmationTitle: String {
        guard isUsedInRoutines else {
            return "Delete Custom Exercise?"
        }

        return "Delete Exercise Used in Routines?"
    }

    var confirmationMessage: String {
        if isUsedInRoutines {
            return "This exercise is used in one or more routines. Deleting it removes it from the exercise library, but existing routine entries will keep their saved exercise name."
        }

        return "This will remove \"\(exerciseName)\" from the exercise library."
    }
}
