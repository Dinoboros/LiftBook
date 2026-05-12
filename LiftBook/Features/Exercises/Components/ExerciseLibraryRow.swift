//
//  ExerciseLibraryRow.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct ExerciseLibraryRow: View {
    let exercise: Exercise
    var isSelected = false
    var isAlreadyAdded = false
    var showsSelectionState = false

    private var subtitle: String {
        if !exercise.primaryMuscles.isEmpty {
            return exercise.primaryMuscles.joined(separator: ", ").capitalized
        }

        return exercise.category.capitalized
    }

    var body: some View {
        HStack(spacing: 12) {
            exerciseText

            Spacer()

            statusContent

            if showsSelectionState {
                Image(systemName: checkmarkSystemImage)
                    .font(.title3)
                    .foregroundStyle(checkmarkColor)
                    .frame(width: 28, height: 28)
            }
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var exerciseText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.body)
                .foregroundStyle(.primary)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var statusContent: some View {
        if exercise.isCustom {
            Text("Custom")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                }
        }

        if isAlreadyAdded {
            Text("Added")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var checkmarkSystemImage: String {
        if isSelected || isAlreadyAdded {
            return "checkmark.circle.fill"
        }

        return "circle"
    }

    private var checkmarkColor: Color {
        if isSelected {
            return .accentColor
        }

        return .secondary
    }
}

#Preview("Picker Row States") {
    List {
        ExerciseLibraryRow(
            exercise: .previewBenchPress,
            showsSelectionState: true
        )

        ExerciseLibraryRow(
            exercise: .previewBenchPress,
            isSelected: true,
            showsSelectionState: true
        )

        ExerciseLibraryRow(
            exercise: .previewBenchPress,
            isAlreadyAdded: true,
            showsSelectionState: true
        )

        ExerciseLibraryRow(
            exercise: .previewCustomExercise,
            showsSelectionState: true
        )
    }
}

private extension Exercise {
    static var previewBenchPress: Exercise {
        Exercise(
            id: "close-grip-bench-press",
            name: "Close-Grip Bench Press",
            category: "strength",
            primaryMuscles: ["triceps"],
            secondaryMuscles: ["chest", "shoulders"]
        )
    }

    static var previewCustomExercise: Exercise {
        Exercise(
            id: "custom-tempo-push-up",
            name: "Tempo Push-Up",
            category: "strength",
            primaryMuscles: ["chest"],
            isCustom: true
        )
    }
}
