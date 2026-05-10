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
        HStack(alignment: .center, spacing: 14) {
            restAdjustmentButton(
                title: "-15sec",
                accessibilityLabel: "Subtract 15 seconds",
                action: onSubtract
            )

            Spacer(minLength: 10)

            timerSummary

            Spacer(minLength: 10)

            restAdjustmentButton(
                title: "+15sec",
                accessibilityLabel: "Add 15 seconds",
                action: onAdd
            )

            skipButton
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(.regularMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: LBExerciseCardMetrics.cardCornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: LBExerciseCardMetrics.cardCornerRadius, style: .continuous)
        )
    }

    private var timerSummary: some View {
        HStack(spacing: 4) {
            Text(WorkoutDurationFormatter.countdownString(from: remainingDuration))
                .font(.headline.monospacedDigit().weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: true, vertical: false)
        }
        .layoutPriority(2)
    }

    private var skipButton: some View {
        Button(action: onSkip) {
            Text("Skip")
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(minWidth: 78, minHeight: 36)
        }
        .buttonStyle(RestTimerOutlineButtonStyle())
        .accessibilityLabel("Skip rest timer")
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
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(minWidth: 70, minHeight: 36)
        }
        .buttonStyle(RestTimerOutlineButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct RestTimerOutlineButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(LBColor.workoutStart)
            .background {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(buttonFill(isPressed: configuration.isPressed))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(LBColor.workoutStart.opacity(0.72), lineWidth: 1.5)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private func buttonFill(isPressed: Bool) -> Color {
        let baseOpacity = colorScheme == .dark ? 0.08 : 0.12
        return LBColor.workoutStart.opacity(isPressed ? baseOpacity + 0.08 : baseOpacity)
    }
}

#Preview("Rest Timer") {
    ActiveWorkoutRestTimerBar(
        remainingDuration: 86,
        onSubtract: {},
        onAdd: {},
        onSkip: {}
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.dark)
}

#Preview("Rest Timer - Large Type") {
    ActiveWorkoutRestTimerBar(
        remainingDuration: 86,
        onSubtract: {},
        onAdd: {},
        onSkip: {}
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility3)
}
