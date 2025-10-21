//
//  ExerciseRowView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 21/10/2025.
//

import SwiftUI

struct ExerciseRowView: View {
    let workoutExercise: WorkoutExercise
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(workoutExercise.exercise?.name ?? "Unknown Exercise")
                    .font(.headline)
                Spacer()
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            // Vue initiale avec en-têtes et premier set
            InitialSetRowView(setNumber: 1, reps: workoutExercise.sets.first?.reps ?? 0, weight: workoutExercise.sets.first?.weight ?? 0.0)

            // Liste des sets supplémentaires
            ForEach(Array(workoutExercise.sets.enumerated()).dropFirst(), id: \.element.id) { index, set in
                AdditionalSetRowView(set: set, setNumber: index + 1)
            }

            Button {
                let newSet = ExerciseSet(
                    exercise: workoutExercise.exercise!,
                    reps: 0,
                    weight: 0,
                    rest: 0
                )
                workoutExercise.addSet(newSet)
            } label: {
                Label("Add Set", systemImage: "plus.circle")
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .buttonStyle(.bordered)
        }
    }
}
