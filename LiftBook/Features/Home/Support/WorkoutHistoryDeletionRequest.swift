//
//  WorkoutHistoryDeletionRequest.swift
//  LiftBook
//
//  Created by Codex on 13/05/2026.
//

import Foundation

struct WorkoutHistoryDeletionRequest {
    let workoutID: UUID
    let workoutName: String

    var confirmationMessage: String {
        "This will permanently delete \"\(workoutName)\"."
    }
}
