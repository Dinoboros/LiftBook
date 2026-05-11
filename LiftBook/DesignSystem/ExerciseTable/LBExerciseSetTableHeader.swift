//
//  LBExerciseSetTableHeader.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct LBExerciseSetTableHeader: View {
    let showsCompletionColumn: Bool

    var body: some View {
        HStack(spacing: 0) {
            Text("Set #")
                .frame(width: LBExerciseCardMetrics.setNumberWidth)

            Text("Reps")
                .frame(maxWidth: .infinity)

            Text("Weight (kg)")
                .frame(maxWidth: .infinity)

            if showsCompletionColumn {
                Color.clear
                    .frame(width: LBExerciseCardMetrics.completionWidth)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
    }
}
