//
//  RoutineDetailSetRow.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct RoutineDetailSetRow: View {
    let setNumber: Int
    let set: RoutineTemplateSet?

    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue

    private var preferredWeightUnit: WeightUnit {
        WeightUnit(rawValue: preferredWeightUnitRawValue) ?? .kilograms
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("\(setNumber)")
                .frame(width: LBExerciseCardMetrics.setNumberWidth)

            LBExerciseSetColumnDivider()

            Text(repsText)
                .frame(maxWidth: .infinity)

            LBExerciseSetColumnDivider()

            Text(weightText)
                .frame(maxWidth: .infinity)
        }
        .font(.body)
        .frame(maxWidth: .infinity, minHeight: LBExerciseCardMetrics.rowHeight)
        .background {
            LBExerciseSetRowBackground(isCompleted: false)
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                style: .continuous
            )
        )
    }

    private var repsText: String {
        guard let reps = set?.reps else {
            return "-"
        }

        return String(reps)
    }

    private var weightText: String {
        LBWeightFormatter.displayText(forKilograms: set?.weight, unit: preferredWeightUnit)
    }
}
