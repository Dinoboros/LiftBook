//
//  WorkoutHistoryCard.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct WorkoutHistoryCard: View {
    let title: String
    let exerciseSummary: String
    let completedAtText: String
    let sourceText: String
    let sourceSystemImage: String
    let onOpen: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            cardContent
                .accessibilityHidden(true)

            openCardTapTarget

            overflowMenu
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
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    metadataChips
                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 8) {
                    metadataChips
                }
            }
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
            .accessibilityLabel("\(title), \(exerciseSummary), \(sourceText), \(completedAtText)")
            .accessibilityHint("Shows workout history details")
    }

    private var overflowMenu: some View {
        LBOverflowMenuButton(accessibilityLabel: "\(title) history options") {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private var metadataChips: some View {
        HStack(spacing: 8) {
            LBInfoChip(
                systemImage: sourceSystemImage,
                text: sourceText,
                tint: LBColor.workoutStart
            )

            LBInfoChip(
                systemImage: "calendar",
                text: completedAtText,
                tint: Color.secondary
            )
        }
    }
}

#Preview("History Card - Dark") {
    WorkoutHistoryCard(
        title: "Upper A",
        exerciseSummary: "Barbell Bench Press, Wide-Grip Lat Pulldown, Side Lateral Raise",
        completedAtText: "26 Apr 2026 at 17:38",
        sourceText: "Routine",
        sourceSystemImage: "list.bullet.rectangle",
        onOpen: {},
        onDelete: {}
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.dark)
}
