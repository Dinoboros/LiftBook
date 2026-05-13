//
//  ExerciseSeedSummaryRow.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

#if DEBUG
import SwiftUI

struct ExerciseSeedSummaryRow: View {
    let exerciseCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "list.bullet.rectangle")
                .foregroundStyle(LBColor.workoutStart)
                .imageScale(.large)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(exerciseCount) exercises")
                    .font(.headline)

                Text("Resources/Files/exercises.json")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
#endif
