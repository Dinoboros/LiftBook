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

    var body: some View {
        WorkoutSummaryCard(
            title: title,
            summary: exerciseSummary
        ) {
            EmptyView()
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
        sourceSystemImage: "list.bullet.rectangle"
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.dark)
}
