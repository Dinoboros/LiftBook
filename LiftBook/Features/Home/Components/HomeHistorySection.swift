//
//  HomeHistorySection.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct HomeHistorySection: View {
    let workouts: [WorkoutSession]
    let rowInsets: EdgeInsets
    let onOpen: (WorkoutSession) -> Void
    let onDelete: (WorkoutSession) -> Void

    var body: some View {
        Section("History") {
            if workouts.isEmpty {
                LBSectionEmptyStateCard(
                    systemImage: "waveform.path.ecg",
                    title: "No workouts logged",
                    message: "Completed workouts will appear here."
                )
                .listRowInsets(rowInsets)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(workouts) { workout in
                    WorkoutHistoryCard(
                        title: workout.name,
                        exerciseSummary: HomeWorkoutFormatter.exerciseSummary(for: workout),
                        completedAtText: HomeWorkoutFormatter.completedAtText(for: workout),
                        sourceText: workout.historySourceTitle,
                        sourceSystemImage: workout.historySourceSystemImage,
                        onOpen: { onOpen(workout) },
                        onDelete: { onDelete(workout) }
                    )
                    .listRowInsets(rowInsets)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        }
    }
}
