//
//  ActiveWorkoutStatsStrip.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftUI

struct ActiveWorkoutStatsStrip: View {
    @Environment(\.colorScheme) private var colorScheme

    let duration: TimeInterval
    let remainingRestDuration: TimeInterval?

    var body: some View {
        HStack(spacing: 0) {
            ActiveWorkoutStatItem(
                title: "Workout",
                value: WorkoutDurationFormatter.string(from: duration)
            )

            divider

            ActiveWorkoutStatItem(
                title: "Rest",
                value: restValue
            )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 58)
        .background {
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                style: .continuous
            )
            .fill(.regularMaterial)

            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                style: .continuous
            )
            .fill(surfaceTint)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                style: .continuous
            )
            .stroke(borderColor, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    private var restValue: String {
        guard let remainingRestDuration else {
            return "--"
        }

        return WorkoutDurationFormatter.countdownString(from: remainingRestDuration)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.18))
            .frame(width: 1, height: 30)
            .padding(.horizontal, 8)
    }

    private var surfaceTint: Color {
        if colorScheme == .dark {
            return LBColor.surface.opacity(0.7)
        }

        return LBColor.surface.opacity(0.82)
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.12)
    }
}

private struct ActiveWorkoutStatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(LBColor.workoutStart)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(value)
                .font(.subheadline.monospacedDigit().weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Workout Stats Strip") {
    ActiveWorkoutStatsStrip(
        duration: 991,
        remainingRestDuration: 89
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.dark)
}
