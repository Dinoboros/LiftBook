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

private struct ExerciseServiceKey: EnvironmentKey {
    static let defaultValue = ExerciseService()
}

private struct RestTimerNotificationServiceKey: EnvironmentKey {
    static let defaultValue = RestTimerNotificationService()
}

private struct RestTimerNotificationCoordinatorKey: EnvironmentKey {
    static let defaultValue = RestTimerNotificationCoordinator.shared
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

    var exerciseService: ExerciseService {
        get { self[ExerciseServiceKey.self] }
        set { self[ExerciseServiceKey.self] = newValue }
    }

    var restTimerNotificationService: RestTimerNotificationService {
        get { self[RestTimerNotificationServiceKey.self] }
        set { self[RestTimerNotificationServiceKey.self] = newValue }
    }

    var restTimerNotificationCoordinator: RestTimerNotificationCoordinator {
        get { self[RestTimerNotificationCoordinatorKey.self] }
        set { self[RestTimerNotificationCoordinatorKey.self] = newValue }
    }
}
