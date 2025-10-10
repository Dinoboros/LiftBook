//
//  Workout.swift
//  LiftBook
//
//  Created by Méryl VALIER on 01/10/2025.
//

import Foundation
import SwiftData

@Model
final class Workout {
    @Attribute(.unique) var id: UUID
    var name: String
    var startedAt: Date
    var completedAt: Date?
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.workout) 
    var exerciseSets: [ExerciseSet]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.exerciseSets = []
        self.startedAt = Date()
        self.completedAt = nil
        self.notes = nil
    }

    var isCompleted: Bool {
        completedAt != nil
    }

    var duration: TimeInterval? {
        guard let completed = completedAt else { return nil }
        return completed.timeIntervalSince(startedAt)
    }

    var totalSets: Int {
        exerciseSets.count
    }
    
    var completedSets: Int {
        exerciseSets.filter { $0.isCompleted }.count
    }
    
    var totalVolume: Double {
        exerciseSets.reduce(0) { $0 + $1.volume }
    }
    
    func addSet(_ set: ExerciseSet) {
        exerciseSets.append(set)
    }
    
    func removeSet(_ set: ExerciseSet) {
        exerciseSets.removeAll { $0.id == set.id }
    }
    
    func complete(withNotes notes: String? = nil) {
        self.completedAt = Date()
        if let notes = notes {
            self.notes = notes
        }
    }
}