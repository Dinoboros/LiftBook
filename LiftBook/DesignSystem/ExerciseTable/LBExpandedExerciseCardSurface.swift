//
//  LBExpandedExerciseCardSurface.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct LBExpandedExerciseCardSurface: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(16)
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

                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                    style: .continuous
                )
                .fill(surfaceSheen)
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                    style: .continuous
                )
                .stroke(borderColor, lineWidth: 1)
            }
    }

    private var surfaceTint: Color {
        if colorScheme == .dark {
            return LBColor.surface.opacity(0.72)
        }

        return LBColor.surface.opacity(0.82)
    }

    private var surfaceSheen: LinearGradient {
        let topOpacity = colorScheme == .dark ? 0.09 : 0.55
        let bottomOpacity = colorScheme == .dark ? 0.02 : 0.14

        return LinearGradient(
            colors: [
                Color.white.opacity(topOpacity),
                Color.white.opacity(bottomOpacity)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.17) : Color.black.opacity(0.12)
    }
}

extension View {
    func lbExpandedExerciseCardSurface() -> some View {
        modifier(LBExpandedExerciseCardSurface())
    }
}
