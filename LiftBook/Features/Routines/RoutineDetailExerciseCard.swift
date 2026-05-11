//
//  RoutineDetailExerciseCard.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI

struct RoutineDetailExerciseCard: View {
    let exercise: RoutineTemplateExercise
    let subtitle: String?

    private var setNumbers: [Int] {
        Array(1...exercise.targetSetCount)
    }

    private var targetSets: [RoutineTemplateSet] {
        exercise.sortedSets
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.exerciseName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 8) {
                LBExerciseSetTableHeader(showsCompletionColumn: false)

                ForEach(setNumbers, id: \.self) { setNumber in
                    RoutineDetailSetRow(
                        setNumber: setNumber,
                        set: targetSets[safe: setNumber - 1]
                    )
                }
            }
        }
        .lbExpandedExerciseCardSurface()
    }
}

private struct RoutineDetailSetRow: View {
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

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
