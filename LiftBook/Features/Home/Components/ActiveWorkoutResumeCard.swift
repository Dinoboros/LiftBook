//
//  ActiveWorkoutResumeCard.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftUI

struct ActiveWorkoutResumeCard: View {
    let workout: WorkoutSession
    let onResume: () -> Void

    private var exerciseCountText: String {
        let count = workout.exercises.count

        if count == 1 {
            return "1 exercise"
        }

        return "\(count) exercises"
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)

                TimelineView(.periodic(from: .now, by: 1)) { timeline in
                    Text(detailText(at: timeline.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text("Started \(workout.startedAt.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .lineLimit(1)

            Spacer()

            Button("Resume", action: onResume)
                .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private func elapsedText(at date: Date) -> String {
        WorkoutDurationFormatter.string(from: workout.elapsedDuration(at: date))
    }

    private func detailText(at date: Date) -> String {
        var details = [
            exerciseCountText,
            elapsedText(at: date)
        ]

        if let restDuration = workout.remainingRestDuration(at: date) {
            details.append("Rest \(WorkoutDurationFormatter.countdownString(from: restDuration))")
        }

        return details.joined(separator: " - ")
    }
}
