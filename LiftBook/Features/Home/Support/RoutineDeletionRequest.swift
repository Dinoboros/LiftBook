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
}
