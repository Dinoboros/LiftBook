//
//  RoutineCard.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

struct RoutineCard: View {
    let title: String
    let exerciseSummary: String
    let onOpen: () -> Void
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .topTrailing) {
                cardContent
                    .accessibilityHidden(true)

                openCardTapTarget

                overflowMenu
                    .padding(16)
            }

            startButton
                .padding(16)
        }
    }

    private var cardContent: some View {
        WorkoutSummaryCard(
            title: title,
            summary: exerciseSummary
        ) {
            Color.clear
                .frame(width: 28, height: 28)
        } footer: {
            HStack {
                Spacer(minLength: 0)
                Color.clear
                    .frame(width: 120, height: 28)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var openCardTapTarget: some View {
        // Gesture-backed so the overflow menu is not presented above another Button.
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: onOpen)
            .accessibilityElement()
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                onOpen()
            }
            .accessibilityLabel("\(title), \(exerciseSummary)")
            .accessibilityHint("Shows routine details")
    }

    private var overflowMenu: some View {
        LBOverflowMenuButton(accessibilityLabel: "\(title) options") {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }

            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var startButton: some View {
        Button(action: onStart) {
            Text("Start workout")
        }
        .buttonStyle(LBPrimaryPillButtonStyle())
        .frame(minWidth: 120, alignment: .center)
        .accessibilityLabel("Start \(title)")
    }
}

#Preview("Routine Card - Dark") {
    RoutineCard(
        title: "Upper A",
        exerciseSummary: "Barbell Bench Press, Wide-Grip Lat Pulldown, Side Lateral Raise",
        onOpen: {},
        onStart: {},
        onEdit: {},
        onDelete: {}
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.dark)
}

#Preview("Routine Card - Light") {
    RoutineCard(
        title: "Upper A",
        exerciseSummary: "Barbell Bench Press, Wide-Grip Lat Pulldown, Side Lateral Raise",
        onOpen: {},
        onStart: {},
        onEdit: {},
        onDelete: {}
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.light)
}
