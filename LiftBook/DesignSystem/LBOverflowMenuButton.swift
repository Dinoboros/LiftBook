//
//  LBOverflowMenuButton.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

struct LBOverflowMenuButton<MenuContent: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    let accessibilityLabel: String
    let menuContent: () -> MenuContent

    init(
        accessibilityLabel: String,
        @ViewBuilder menuContent: @escaping () -> MenuContent
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.menuContent = menuContent
    }

    var body: some View {
        Menu {
            menuContent()
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: 28, height: 28)
                .background {
                    Circle()
                        .fill(.regularMaterial)

                    Circle()
                        .fill(backgroundColor)
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(borderOpacity), lineWidth: 0.8)
                }
                .shadow(color: shadowColor, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var backgroundColor: Color {
        if colorScheme == .dark {
            return Color.black.opacity(0.16)
        }

        return Color.white.opacity(0.36)
    }

    private var borderOpacity: Double {
        colorScheme == .dark ? 0.16 : 0.55
    }

    private var shadowColor: Color {
        colorScheme == .dark ? Color.black.opacity(0.32) : Color.black.opacity(0.1)
    }
}
