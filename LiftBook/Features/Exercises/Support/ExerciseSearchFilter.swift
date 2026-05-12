//
//  ExerciseSearchFilter.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import Foundation

enum ExerciseSearchFilter {
    static func filteredExercises(
        from exercises: [Exercise],
        matching searchText: String
    ) -> [Exercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return exercises
        }

        return exercises.filter { exercise in
            exercise.name.localizedStandardContains(query)
                || exercise.aliases.contains { $0.localizedStandardContains(query) }
                || exercise.primaryMuscles.contains { $0.localizedStandardContains(query) }
        }
    }
}
