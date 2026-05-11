//
//  LBAddSetButtonStyle.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct LBAddSetButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(LBColor.workoutStart)
            .frame(maxWidth: .infinity, minHeight: 38)
            .background {
                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                    style: .continuous
                )
                .fill(backgroundColor(isPressed: configuration.isPressed))
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                    style: .continuous
                )
                .stroke(borderColor, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        let baseOpacity = colorScheme == .dark ? 0.025 : 0.04
        return LBColor.workoutStart.opacity(isPressed ? baseOpacity + 0.06 : baseOpacity)
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.11)
    }
}
