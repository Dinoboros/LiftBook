//
//  ActiveWorkoutError.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

struct ActiveWorkoutError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
