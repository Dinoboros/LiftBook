//
//  LBWeightFormatter.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import Foundation

enum LBWeightFormatter {
    private static let kilogramsPerPound = 0.45359237

    static func displayValue(forKilograms kilograms: Double, unit: WeightUnit) -> Double {
        switch unit {
        case .kilograms:
            return kilograms
        case .pounds:
            return kilograms / kilogramsPerPound
        }
    }

    static func kilograms(fromDisplayValue value: Double, unit: WeightUnit) -> Double {
        switch unit {
        case .kilograms:
            return value
        case .pounds:
            return value * kilogramsPerPound
        }
    }

    static func displayText(forKilograms kilograms: Double?, unit: WeightUnit) -> String {
        guard let kilograms else {
            return "-"
        }

        return text(for: displayValue(forKilograms: kilograms, unit: unit))
    }

    static func editableText(forKilograms kilograms: Double?, unit: WeightUnit) -> String {
        guard let kilograms else {
            return ""
        }

        return text(for: displayValue(forKilograms: kilograms, unit: unit))
    }

    static func kilograms(fromDisplayText text: String, unit: WeightUnit) -> Double? {
        let trimmedValue = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !trimmedValue.isEmpty, let value = Double(trimmedValue), value.isFinite else {
            return nil
        }

        return kilograms(fromDisplayValue: value, unit: unit)
    }

    static func text(for value: Double) -> String {
        let roundedValue = (value * 10).rounded() / 10

        if roundedValue.rounded() == roundedValue {
            return String(Int(roundedValue))
        }

        return String(roundedValue)
    }
}
