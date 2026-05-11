//
//  LBExerciseSetRowBackground.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct LBExerciseSetRowBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    let isCompleted: Bool

    var body: some View {
        RoundedRectangle(
            cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
            style: .continuous
        )
        .fill(baseColor)
        .overlay {
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                style: .continuous
            )
            .fill(highlight)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                style: .continuous
            )
            .stroke(borderColor, lineWidth: 1)
        }
    }

    private var baseColor: Color {
        if colorScheme == .dark {
            return Color.white.opacity(isCompleted ? 0.06 : 0.035)
        }

        return Color.black.opacity(isCompleted ? 0.05 : 0.025)
    }

    private var highlight: Color {
        if isCompleted {
            return LBColor.workoutStart.opacity(colorScheme == .dark ? 0.16 : 0.12)
        }

        return Color.clear
    }

    private var borderColor: Color {
        if isCompleted {
            return LBColor.workoutStart.opacity(0.65)
        }

        return colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.12)
    }
}
