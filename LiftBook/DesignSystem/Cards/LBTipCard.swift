//
//  LBTipCard.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct LBTipCard: View {
    var systemImage = "sparkle"
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(LBColor.workoutStart)
                .frame(width: 20)

            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .lbCardSurface()
    }
}
