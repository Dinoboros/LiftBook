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

    var weightValue: Double? {
        weightValue(unit: .kilograms)
    }

    func weightValue(unit: WeightUnit) -> Double? {
        if weight == originalWeightText {
            return originalWeightInKilograms
        }

        return LBWeightFormatter.kilograms(fromDisplayText: weight, unit: unit)
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
