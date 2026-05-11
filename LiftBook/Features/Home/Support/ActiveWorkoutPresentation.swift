//
//  ActiveWorkoutPresentation.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

enum ActiveWorkoutPresentation: Identifiable {
    case session(UUID)

    var id: UUID {
        switch self {
        case .session(let workoutSessionID):
            return workoutSessionID
        }
    }

    var workoutSessionID: UUID {
        switch self {
        case .session(let workoutSessionID):
            return workoutSessionID
        }
    }
}
