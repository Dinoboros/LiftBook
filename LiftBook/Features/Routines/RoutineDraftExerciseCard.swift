//
//  RoutineDraftExerciseCard.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import SwiftUI

struct RoutineDraftExerciseCard: View {
    @Binding var exercise: RoutineExerciseDraft
    let showsSubtitle: Bool
    let showsSetInputs: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(exercise.exerciseName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)

                    if showsSubtitle, !exercise.subtitle.isEmpty {
                        Text(exercise.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                LBOverflowMenuButton(size: 44, accessibilityLabel: "Exercise options") {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                }
            }

            VStack(spacing: 8) {
                LBExerciseSetTableHeader(showsCompletionColumn: false)

                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    RoutineDraftSetRow(
                        setNumber: index + 1,
                        set: $exercise.sets[index],
                        canDelete: exercise.sets.count > 1,
                        showsInputs: showsSetInputs,
                        onDelete: { deleteSet(id: set.id) }
                    )
                }
            }

            Button(action: addSet) {
                Label("Add set", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(LBAddSetButtonStyle())
        }
        .lbExpandedExerciseCardSurface()
    }

    private func addSet() {
        exercise.sets.append(RoutineSetDraft())
    }

    private func deleteSet(id: UUID) {
        guard exercise.sets.count > 1 else {
            return
        }

        exercise.sets.removeAll { $0.id == id }
    }
}

private struct RoutineDraftSetRow: View {
    let setNumber: Int
    @Binding var set: RoutineSetDraft
    let canDelete: Bool
    let showsInputs: Bool
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

                if showsInputs {
                    TextField("-", text: $set.reps)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("-")
                        .frame(maxWidth: .infinity)
                }

                LBExerciseSetColumnDivider()

                if showsInputs {
                    TextField("-", text: $set.weight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.plain)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("-")
                        .frame(maxWidth: .infinity)
                }
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
