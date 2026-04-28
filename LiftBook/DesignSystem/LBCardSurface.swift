//
//  LBCardSurface.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

struct LBCardSurface: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    var isPressed = false

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: LBRadius.card, style: .continuous)
                    .fill(.regularMaterial)

                RoundedRectangle(cornerRadius: LBRadius.card, style: .continuous)
                    .fill(surfaceTint)

                RoundedRectangle(cornerRadius: LBRadius.card, style: .continuous)
                    .fill(surfaceSheen)
            }
            .overlay {
                RoundedRectangle(cornerRadius: LBRadius.card, style: .continuous)
                    .stroke(borderGradient, lineWidth: 1)
            }
            .scaleEffect(isPressed ? 0.985 : 1)
            .animation(.snappy(duration: 0.18), value: isPressed)
    }

    private var surfaceTint: Color {
        if colorScheme == .dark {
            return LBColor.surface.opacity(0.78)
        }

        return LBColor.surface.opacity(0.92)
    }

    private var surfaceSheen: LinearGradient {
        let leadingOpacity = colorScheme == .dark ? 0.16 : 0.7
        let trailingOpacity = colorScheme == .dark ? 0.03 : 0.18

        return LinearGradient(
            colors: [
                Color.white.opacity(leadingOpacity),
                Color.white.opacity(trailingOpacity)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderGradient: LinearGradient {
        let primaryOpacity = colorScheme == .dark ? 0.2 : 0.55
        let secondaryOpacity = colorScheme == .dark ? 0.08 : 0.18

        return LinearGradient(
            colors: [
                Color.white.opacity(primaryOpacity),
                Color.primary.opacity(secondaryOpacity)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

}

extension View {
    func lbCardSurface(isPressed: Bool = false) -> some View {
        modifier(LBCardSurface(isPressed: isPressed))
    }
}
