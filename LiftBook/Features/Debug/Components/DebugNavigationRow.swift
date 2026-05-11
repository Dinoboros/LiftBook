//
//  DebugNavigationRow.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct DebugNavigationRow: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
                .foregroundStyle(LBColor.workoutStart)
        }
    }
}
