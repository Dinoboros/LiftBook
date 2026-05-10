//
//  HomeRoute.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation

enum HomeRoute: Hashable {
    case routineEditor
    case routineDetail(UUID)
    case workoutHistoryDetail(UUID)
    case appDebug
}
