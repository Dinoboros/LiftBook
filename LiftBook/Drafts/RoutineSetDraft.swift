//
//  RoutineSetDraft.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

struct RoutineSetDraft: Identifiable, Equatable {
    let id = UUID()
    var reps = ""
    var weight = ""
    private var originalWeightText: String?
    private var originalWeightInKilograms: Double?

    var repsValue: Int? {
        let trimmedValue = reps.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : Int(trimmedValue)
    }

    var hasValidReps: Bool {
        let trimmedValue = reps.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty else {
            return true
        }

        guard let reps = repsValue else {
            return false
        }

        return reps > 0
    }

    var weightValue: Double? {
        weightValue(unit: .kilograms)
    }

    func weightValue(unit: WeightUnit) -> Double? {
        if weight == originalWeightText {
            return originalWeightInKilograms
        }

        return LBWeightFormatter.kilograms(fromDisplayText: weight, unit: unit)
    }

    func hasValidWeight(unit: WeightUnit) -> Bool {
        let trimmedValue = weight.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedValue.isEmpty else {
            return true
        }

        guard let weightValue = weightValue(unit: unit) else {
            return false
        }

        return weightValue >= 0
    }

    func hasValidValues(unit: WeightUnit) -> Bool {
        hasValidReps && hasValidWeight(unit: unit)
    }

    init() {}

    init(set: RoutineTemplateSet, weightUnit: WeightUnit = .kilograms) {
        reps = Self.text(for: set.reps)
        originalWeightInKilograms = set.weight
        originalWeightText = LBWeightFormatter.editableText(
            forKilograms: set.weight,
            unit: weightUnit
        )
        weight = originalWeightText ?? ""
    }

    private static func text(for reps: Int?) -> String {
        guard let reps else {
            return ""
        }

        return String(reps)
    }

}
