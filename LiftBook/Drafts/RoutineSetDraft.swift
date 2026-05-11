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

    var repsValue: Int? {
        let trimmedValue = reps.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : Int(trimmedValue)
    }

    var weightValue: Double? {
        let trimmedValue = weight
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !trimmedValue.isEmpty, let weight = Double(trimmedValue), weight.isFinite else {
            return nil
        }

        return weight
    }

    init() {}

    init(set: RoutineTemplateSet) {
        reps = Self.text(for: set.reps)
        weight = Self.text(for: set.weight)
    }

    private static func text(for reps: Int?) -> String {
        guard let reps else {
            return ""
        }

        return String(reps)
    }

    private static func text(for weight: Double?) -> String {
        guard let weight else {
            return ""
        }

        if weight.rounded() == weight {
            return String(Int(weight))
        }

        return String(weight)
    }
}
