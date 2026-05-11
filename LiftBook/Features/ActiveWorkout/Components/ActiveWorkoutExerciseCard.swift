//
//  ActiveWorkoutExerciseCard.swift
//  LiftBook
//
//  Created by Codex on 26/04/2026.
//

import SwiftUI

struct ActiveWorkoutExerciseCard: View {
    let exercise: WorkoutSessionExercise
    let subtitle: String?
    let onDeleteExercise: () -> Void
    let onAddSet: () -> Void
    let onDeleteSet: (WorkoutSet) -> Void
    let onUpdateSet: (WorkoutSet, Int?, Double?) -> Void
    let onToggleSetCompleted: (WorkoutSet) -> Void

    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue

    private var preferredWeightUnit: WeightUnit {
        WeightUnit(rawValue: preferredWeightUnitRawValue) ?? .kilograms
    }

    private var sortedSets: [WorkoutSet] {
        exercise.sortedSets
    }

    var body: some View {
        let sortedWorkoutSets = sortedSets
        let canDeleteSet = sortedWorkoutSets.count > 1

        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
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

                Spacer()

                LBOverflowMenuButton(size: 44, accessibilityLabel: "Exercise options") {
                    Button(role: .destructive, action: onDeleteExercise) {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                }
            }

            VStack(spacing: 8) {
                LBExerciseSetTableHeader(showsCompletionColumn: true)

                ForEach(Array(sortedWorkoutSets.enumerated()), id: \.element.id) { index, set in
                    ActiveWorkoutSetRow(
                        setNumber: index + 1,
                        set: set,
                        weightUnit: preferredWeightUnit,
                        canDelete: canDeleteSet,
                        onDelete: { onDeleteSet(set) },
                        onUpdate: { reps, weight in
                            onUpdateSet(set, reps, weight)
                        },
                        onToggleCompleted: {
                            onToggleSetCompleted(set)
                        }
                    )
                }
            }

            Button(action: onAddSet) {
                Label("Add set", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(LBAddSetButtonStyle())
        }
        .lbExpandedExerciseCardSurface()
    }
}
