//
//  ActiveWorkoutExerciseCard.swift
//  LiftBook
//
//  Created by Codex on 26/04/2026.
//

import SwiftData
import SwiftUI

struct ActiveWorkoutExerciseCard: View {
    @Environment(\.modelContext) private var modelContext

    let exercise: WorkoutSessionExercise
    let onDeleteExercise: () -> Void

    private var sortedSets: [WorkoutSet] {
        exercise.sets.sorted { $0.sortOrder < $1.sortOrder }
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
                        onDelete: { deleteSet(set) }
                    )
                }
            }

            Button(action: addSet) {
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

    private func addSet() {
        let nextSortOrder = (exercise.sets.map(\.sortOrder).max() ?? -1) + 1
        let workoutSet = WorkoutSet(sortOrder: nextSortOrder)
        modelContext.insert(workoutSet)
        exercise.sets.append(workoutSet)
        saveChanges()
    }

    private func deleteSet(_ set: WorkoutSet) {
        guard exercise.sets.count > 1 else {
            return
        }

        exercise.sets.removeAll { $0.id == set.id }
        modelContext.delete(set)
        normalizeSetSortOrders()
        saveChanges()
    }

    private func normalizeSetSortOrders() {
        for (index, set) in sortedSets.enumerated() {
            set.sortOrder = index
        }
    }

    private func saveChanges() {
        try? modelContext.save()
    }
}
