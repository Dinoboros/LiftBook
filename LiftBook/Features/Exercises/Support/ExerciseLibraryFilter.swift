//
//  ExerciseLibraryFilter.swift
//  LiftBook
//
//  Created by Codex on 14/05/2026.
//

import Foundation

struct ExerciseLibraryFilter: Equatable, Hashable {
    var equipment: Set<String> = []
    var muscles: Set<String> = []

    var isActive: Bool {
        !equipment.isEmpty || !muscles.isEmpty
    }

    var activeCount: Int {
        equipment.count + muscles.count
    }

    var sortedEquipment: [String] {
        sortedValues(equipment)
    }

    var sortedMuscles: [String] {
        sortedValues(muscles)
    }

    mutating func toggleEquipment(_ value: String) {
        equipment = Self.toggled(value, in: equipment)
    }

    mutating func toggleMuscle(_ value: String) {
        muscles = Self.toggled(value, in: muscles)
    }

    mutating func removeEquipment(_ value: String) {
        equipment = Self.removing(value, from: equipment)
    }

    mutating func removeMuscle(_ value: String) {
        muscles = Self.removing(value, from: muscles)
    }

    func containsEquipment(_ value: String) -> Bool {
        Self.contains(value, in: equipment)
    }

    func containsMuscle(_ value: String) -> Bool {
        Self.contains(value, in: muscles)
    }

    nonisolated static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    static func displayText(for value: String) -> String {
        value.capitalized
    }

    private static func toggled(_ value: String, in values: Set<String>) -> Set<String> {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty else {
            return values
        }

        var updatedValues = removing(trimmedValue, from: values)

        if updatedValues.count == values.count {
            updatedValues.insert(trimmedValue)
        }

        return updatedValues
    }

    private static func removing(_ value: String, from values: Set<String>) -> Set<String> {
        let normalizedValue = normalized(value)

        return values.filter { normalized($0) != normalizedValue }
    }

    private static func contains(_ value: String, in values: Set<String>) -> Bool {
        let normalizedValue = normalized(value)

        return values.contains { normalized($0) == normalizedValue }
    }

    private func sortedValues(_ values: Set<String>) -> [String] {
        values.sorted { first, second in
            first.localizedStandardCompare(second) == .orderedAscending
        }
    }
}

struct ExerciseLibraryFilterOptions: Equatable {
    let equipment: [String]
    let muscles: [String]

    static func make(from exercises: [Exercise]) -> ExerciseLibraryFilterOptions {
        ExerciseLibraryFilterOptions(
            equipment: orderedValues(
                defaults: ExerciseEditorTokens.equipment,
                customValues: exercises.flatMap(\.equipment)
            ),
            muscles: orderedValues(
                defaults: ExerciseEditorTokens.muscles,
                customValues: exercises.flatMap { $0.primaryMuscles + $0.secondaryMuscles }
            )
        )
    }

    private static func orderedValues(defaults: [String], customValues: [String]) -> [String] {
        var seenValues = Set<String>()
        var orderedValues: [String] = []

        func append(_ value: String) {
            let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedValue = ExerciseLibraryFilter.normalized(trimmedValue)

            guard !trimmedValue.isEmpty, !seenValues.contains(normalizedValue) else {
                return
            }

            seenValues.insert(normalizedValue)
            orderedValues.append(trimmedValue)
        }

        defaults.forEach(append)

        customValues
            .sorted { first, second in
                first.localizedStandardCompare(second) == .orderedAscending
            }
            .forEach(append)

        return orderedValues
    }
}
