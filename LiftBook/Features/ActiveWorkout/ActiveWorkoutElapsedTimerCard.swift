//
//  ActiveWorkoutElapsedTimerCard.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftUI

struct ActiveWorkoutElapsedTimerCard: View {
    let duration: TimeInterval

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "timer")
                .font(.title2.weight(.semibold))
                .foregroundStyle(LBColor.workoutStart)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 4) {
                Text("Workout Time")
                    .font(.subheadline.weight(.semibold))

                Text(WorkoutDurationFormatter.string(from: duration))
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lbExpandedExerciseCardSurface()
        .accessibilityElement(children: .combine)
    }
}

