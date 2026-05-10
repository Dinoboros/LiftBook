//
//  ActiveWorkoutRestTimerBar.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftUI

struct ActiveWorkoutRestTimerBar: View {
    @Environment(\.colorScheme) private var colorScheme

    let remainingDuration: TimeInterval
    let onSubtract: () -> Void
    let onAdd: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "hourglass")
                .font(.headline.weight(.semibold))
                .foregroundStyle(LBColor.workoutStart)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text("Rest")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(WorkoutDurationFormatter.countdownString(from: remainingDuration))
                    .font(.headline.monospacedDigit().weight(.semibold))
            }

            Spacer()

            HStack(spacing: 6) {
                restAdjustmentButton(
                    title: "-15sec",
                    accessibilityLabel: "Subtract 15 seconds",
                    action: onSubtract
                )

                restAdjustmentButton(
                    title: "+15sec",
                    accessibilityLabel: "Add 15 seconds",
                    action: onAdd
                )
            }

            Button(action: onSkip) {
                Label("Skip", systemImage: "forward.end.fill")
            }
            .font(.subheadline.weight(.semibold))
            .buttonStyle(.bordered)
            .tint(LBColor.workoutStart)
            .accessibilityLabel("Skip rest timer")
        }
        .padding(14)
        .background(.regularMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: LBExerciseCardMetrics.cardCornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: LBExerciseCardMetrics.cardCornerRadius, style: .continuous)
        )
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.12)
    }

    private func restAdjustmentButton(
        title: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .frame(minWidth: 56, minHeight: 34)
        }
        .buttonStyle(.bordered)
        .tint(LBColor.workoutStart)
        .accessibilityLabel(accessibilityLabel)
    }
}

