//
//  RoutineDetailSummaryCard.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct RoutineDetailSummaryCard: View {
    let title: String
    let summary: String
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Button(action: onStart) {
                Label("Start Workout", systemImage: "play.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LBColor.workoutStart)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start \(title)")
        }
        .padding(18)
        .lbCardSurface()
    }
}
