//
//  WorkoutStartRequest.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

enum WorkoutStartRequest: Identifiable {
    case empty(UUID, returnsHomeFirst: Bool)
    case routine(UUID, returnsHomeFirst: Bool)

    var id: UUID {
        switch self {
        case .empty(let id, _), .routine(let id, _):
            return id
        }
    }

    var shouldReturnHomeFirst: Bool {
        switch self {
        case .empty(_, let returnsHomeFirst), .routine(_, let returnsHomeFirst):
            return returnsHomeFirst
        }
    }
}
