//
//  RoutineDraftSetRow.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct RoutineDraftSetRow: View {
    let setNumber: Int
    @Binding var set: RoutineSetDraft
    let canDelete: Bool
    let onDelete: () -> Void

    var body: some View {
        LBSwipeDeleteSetRow(
            canDelete: canDelete,
            deleteAccessibilityLabel: "Delete set \(setNumber)",
            onDelete: onDelete
        ) {
            HStack(spacing: 0) {
                Text("\(setNumber)")
                    .frame(width: LBExerciseCardMetrics.setNumberWidth)

                LBExerciseSetColumnDivider()

                TextField("-", text: $set.reps)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)

                LBExerciseSetColumnDivider()

                TextField("-", text: $set.weight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)
            }
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
        .font(.body)
    }
}
