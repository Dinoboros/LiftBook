//
//  LBInfoChip.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

struct LBInfoChip: View {
    @Environment(\.colorScheme) private var colorScheme

    let systemImage: String
    let text: String
    var tint = LBColor.workoutStart

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 16)

            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 8)
        .frame(height: 28)
        .background {
            RoundedRectangle(cornerRadius: LBRadius.chip, style: .continuous)
                .fill(backgroundColor)
        }
        .overlay {
            RoundedRectangle(cornerRadius: LBRadius.chip, style: .continuous)
                .stroke(Color.white.opacity(borderOpacity), lineWidth: 0.7)
        }
    }

    private var backgroundColor: Color {
        if colorScheme == .dark {
            return Color.white.opacity(0.08)
        }

        return Color.black.opacity(0.045)
    }

    private var borderOpacity: Double {
        colorScheme == .dark ? 0.06 : 0.35
    }
}
