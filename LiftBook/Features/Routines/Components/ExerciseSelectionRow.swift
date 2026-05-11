//
//  ExerciseSelectionRow.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct ExerciseSelectionRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let isAlreadyAdded: Bool
    let onToggle: () -> Void
    let onShowDetail: () -> Void

    private var subtitle: String {
        if !exercise.primaryMuscles.isEmpty {
            return exercise.primaryMuscles.joined(separator: ", ").capitalized
        }

        return exercise.category.capitalized
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                HStack(spacing: 12) {
                    exerciseText

                    Spacer()

                    statusContent

                    Image(systemName: checkmarkSystemImage)
                        .font(.title3)
                        .foregroundStyle(checkmarkColor)
                        .frame(width: 28, height: 28)
                }
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .disabled(isAlreadyAdded)

            Button(action: onShowDetail) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Show details for \(exercise.name)")
        }
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
