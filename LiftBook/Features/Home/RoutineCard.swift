//
//  RoutineCard.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

private struct WorkoutSummaryCard<HeaderAccessory: View, Footer: View>: View {
    let title: String
    let summary: String
    let headerAccessory: () -> HeaderAccessory
    let footer: () -> Footer

    init(
        title: String,
        summary: String,
        @ViewBuilder headerAccessory: @escaping () -> HeaderAccessory,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = title
        self.summary = summary
        self.headerAccessory = headerAccessory
        self.footer = footer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 10)

                headerAccessory()
            }

            Text(summary)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            footer()
        }
        .padding(16)
        .lbCardSurface()
        .accessibilityElement(children: .contain)
    }
}

struct RoutineCard: View {
    let title: String
    let exerciseSummary: String
    let onOpen: () -> Void
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onOpen) {
            cardContent
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            overflowMenu
                .padding(16)
        }
        .overlay(alignment: .bottomTrailing) {
            startButton
                .padding(16)
        }
        .accessibilityHint("Shows routine details")
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
