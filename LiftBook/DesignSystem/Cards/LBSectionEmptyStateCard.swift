//
//  LBSectionEmptyStateCard.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct LBSectionEmptyStateCard: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LBColor.workoutStart.opacity(0.06))

                Circle()
                    .stroke(
                        Color.secondary.opacity(0.24),
                        style: StrokeStyle(lineWidth: 1, dash: [3, 4])
                    )

                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(LBColor.workoutStart)
            }
            .frame(width: 48, height: 48)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .leading)
        .lbCardSurface()
    }
}
