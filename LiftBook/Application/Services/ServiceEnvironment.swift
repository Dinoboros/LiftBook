//
//  ServiceEnvironment.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import SwiftUI

private struct RoutineServiceKey: EnvironmentKey {
    static let defaultValue = RoutineService()
}

private struct WorkoutServiceKey: EnvironmentKey {
    static let defaultValue = WorkoutService()
}

extension EnvironmentValues {
    var routineService: RoutineService {
        get { self[RoutineServiceKey.self] }
        set { self[RoutineServiceKey.self] = newValue }
    }

    var workoutService: WorkoutService {
        get { self[WorkoutServiceKey.self] }
        set { self[WorkoutServiceKey.self] = newValue }
    }
}
