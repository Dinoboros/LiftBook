//
//  LBOverflowMenuButton.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

struct LBOverflowMenuButton<MenuContent: View>: View {
    @Environment(\.colorScheme) private var colorScheme

    let size: CGFloat
    let accessibilityLabel: String
    let menuContent: () -> MenuContent
    @State private var isShowingActions = false

    init(
        size: CGFloat = 28,
        accessibilityLabel: String,
        @ViewBuilder menuContent: @escaping () -> MenuContent
    ) {
        self.size = size
        self.accessibilityLabel = accessibilityLabel
        self.menuContent = menuContent
    }

    var body: some View {
        Button {
            isShowingActions = true
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)
                .frame(width: size, height: size)
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
        .confirmationDialog(
            accessibilityLabel,
            isPresented: $isShowingActions,
            titleVisibility: .hidden
        ) {
            menuContent()
        }
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
