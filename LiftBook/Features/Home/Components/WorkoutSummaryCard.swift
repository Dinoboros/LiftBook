//
//  WorkoutSummaryCard.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct WorkoutSummaryCard<HeaderAccessory: View, Footer: View>: View {
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
