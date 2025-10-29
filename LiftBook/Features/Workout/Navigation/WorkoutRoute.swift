//
//  WorkoutRoute.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import Foundation

enum WorkoutRoute: Hashable {
    case emptyWorkout
    case newWorkoutTemplate
    case startWorkout(Workout)
}
