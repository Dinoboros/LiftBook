//
//  ActiveWorkoutExerciseCard.swift
//  LiftBook
//
//  Created by Codex on 26/04/2026.
//

import SwiftUI

struct ActiveWorkoutExerciseCard: View {
    let exercise: WorkoutSessionExercise
    let onDeleteExercise: () -> Void
    let onAddSet: () -> Void
    let onDeleteSet: (WorkoutSet) -> Void
    let onUpdateSet: (WorkoutSet, Int?, Double?) -> Void
    let onToggleSetCompleted: (WorkoutSet) -> Void

    private var sortedSets: [WorkoutSet] {
        exercise.sortedSets
    }

    var body: some View {
        let sortedWorkoutSets = sortedSets
        let canDeleteSet = sortedWorkoutSets.count > 1

        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                Text(exercise.exerciseName)
                    .font(.title3.weight(.semibold))

                Spacer()

                Menu {
                    Button(role: .destructive, action: onDeleteExercise) {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Exercise options")
            }

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Text("Set #")
                        .frame(maxWidth: .infinity)
                    Text("Reps")
                        .frame(maxWidth: .infinity)
                    Text("Weight")
                        .frame(maxWidth: .infinity)
                    Color.clear
                        .frame(width: 75)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                ForEach(Array(sortedWorkoutSets.enumerated()), id: \.element.id) { index, set in
                    ActiveWorkoutSetRow(
                        setNumber: index + 1,
                        set: set,
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
            .buttonStyle(.bordered)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}
