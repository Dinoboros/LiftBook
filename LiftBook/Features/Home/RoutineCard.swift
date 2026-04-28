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
    let onStart: () -> Void
    let onEdit: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 10)

                LBOverflowMenuButton(accessibilityLabel: "\(title) options") {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }

                    Button(action: onDuplicate) {
                        Label("Duplicate", systemImage: "doc.on.doc")
                    }

                    Button(role: .destructive, action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            Text(exerciseSummary)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Spacer(minLength: 0)
                startButton
            }
        }
        .padding(16)
        .lbCardSurface()
        .accessibilityElement(children: .contain)
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
        onStart: {},
        onEdit: {},
        onDuplicate: {},
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
        onStart: {},
        onEdit: {},
        onDuplicate: {},
        onDelete: {}
    )
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.light)
}
