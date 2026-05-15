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
        matching searchText: String,
        filter: ExerciseLibraryFilter = ExerciseLibraryFilter()
    ) -> [Exercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let selectedEquipment = normalizedSet(filter.equipment)
        let selectedMuscles = normalizedSet(filter.muscles)

        return exercises.filter { exercise in
            matchesSearch(exercise, query: query)
                && matchesEquipment(exercise, selectedEquipment: selectedEquipment)
                && matchesMuscles(exercise, selectedMuscles: selectedMuscles)
        }
    }

    private static func matchesSearch(_ exercise: Exercise, query: String) -> Bool {
        guard !query.isEmpty else {
            return true
        }

        return exercise.name.localizedStandardContains(query)
            || exercise.aliases.contains { $0.localizedStandardContains(query) }
            || exercise.primaryMuscles.contains { $0.localizedStandardContains(query) }
    }

    private static func matchesEquipment(
        _ exercise: Exercise,
        selectedEquipment: Set<String>
    ) -> Bool {
        guard !selectedEquipment.isEmpty else {
            return true
        }

        let exerciseEquipment = normalizedSet(exercise.equipment)

        if selectedEquipment.contains("none"), exerciseEquipment.isEmpty || exerciseEquipment.contains("none") {
            return true
        }

        return !selectedEquipment.isDisjoint(with: exerciseEquipment)
    }

    private static func matchesMuscles(
        _ exercise: Exercise,
        selectedMuscles: Set<String>
    ) -> Bool {
        guard !selectedMuscles.isEmpty else {
            return true
        }

        let exerciseMuscles = normalizedSet(exercise.primaryMuscles + exercise.secondaryMuscles)

        return !selectedMuscles.isDisjoint(with: exerciseMuscles)
    }

    private static func normalizedSet<Values: Sequence>(_ values: Values) -> Set<String>
        where Values.Element == String
    {
        Set(
            values
                .map(ExerciseLibraryFilter.normalized)
                .filter { !$0.isEmpty }
        )
    }
}
