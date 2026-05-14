//
//  RoutineDeletionRequest.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

struct RoutineDeletionRequest {
    let routineID: UUID
    let routineName: String
    let hasActiveWorkout: Bool

    var confirmationTitle: String {
        guard hasActiveWorkout else {
            return "Delete Routine?"
        }

        return "Delete Routine Used by Active Workout?"
    }

    var confirmationMessage: String {
        if hasActiveWorkout {
            return "An active workout was started from \"\(routineName)\". Deleting the routine will keep the active workout, but it can no longer update this routine."
        }

        return "This will permanently delete \"\(routineName)\"."
    }
}
