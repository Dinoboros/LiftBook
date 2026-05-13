//
//  ExerciseSeedDebugRow.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

#if DEBUG
import Foundation
import SwiftUI

struct ExerciseSeedDebugRow: View {
    let exercise: ExerciseSeedDebugExercise

    private var muscleText: String {
        exercise.primaryMuscles
            .map(\.capitalized)
            .joined(separator: ", ")
    }

    private var equipmentText: String {
        guard !exercise.equipment.isEmpty else {
            return "No equipment"
        }

        return exercise.equipment
            .map(\.capitalized)
            .joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.headline)

            if !muscleText.isEmpty {
                Text(muscleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Label(exercise.category.capitalized, systemImage: "tag")
                Label(equipmentText, systemImage: "dumbbell")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !exercise.aliases.isEmpty {
                Text("Aliases: \(exercise.aliases.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
#endif
