//
//  LBSplitActionControl.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

struct LBSplitAction {
    let title: String
    let systemImage: String
    let action: () -> Void

    init(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }
}

struct LBSplitActionControl: View {
    @Environment(\.colorScheme) private var colorScheme

    let leadingAction: LBSplitAction
    let trailingAction: LBSplitAction

    var body: some View {
        HStack(spacing: 0) {
            splitButton(for: leadingAction)

            divider

            splitButton(for: trailingAction)
        }
        .frame(minHeight: 96)
        .lbCardSurface()
    }

    private func splitButton(for action: LBSplitAction) -> some View {
        Button(action: action.action) {
            VStack(spacing: 9) {
                Image(systemName: action.systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(LBColor.workoutStart)

                Text(action.title)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.82)
            }
            .frame(maxWidth: .infinity, minHeight: 96)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.title)
    }

    private var divider: some View {
        Rectangle()
            .fill(dividerColor)
            .frame(width: 1)
            .padding(.vertical, 1)
    }

    private var dividerColor: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.12)
        }

        return Color.black.opacity(0.12)
    }
}

#Preview("Split Action Control - Dark") {
    LBSplitActionControl(
        leadingAction: LBSplitAction(
            title: "Start Empty Workout",
            systemImage: "plus.circle.fill",
            action: {}
        ),
        trailingAction: LBSplitAction(
            title: "Create Routine",
            systemImage: "doc.badge.plus",
            action: {}
        )
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.dark)
}
