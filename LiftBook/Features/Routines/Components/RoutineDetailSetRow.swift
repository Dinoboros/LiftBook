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
        guard let weight = set?.weight else {
            return "-"
        }

        if weight.rounded() == weight {
            return String(Int(weight))
        }

        return String(weight)
    }
}
