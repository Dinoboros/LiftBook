//
//  LBExerciseSetTableHeader.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct LBExerciseSetTableHeader: View {
    let showsCompletionColumn: Bool

    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue

    private var preferredWeightUnit: WeightUnit {
        WeightUnit(rawValue: preferredWeightUnitRawValue) ?? .kilograms
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("Set #")
                .frame(width: LBExerciseCardMetrics.setNumberWidth)

            Text("Reps")
                .frame(maxWidth: .infinity)

            Text("Weight (\(preferredWeightUnit.rawValue))")
                .frame(maxWidth: .infinity)

            if showsCompletionColumn {
                Color.clear
                    .frame(width: LBExerciseCardMetrics.completionWidth)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
    }
}
