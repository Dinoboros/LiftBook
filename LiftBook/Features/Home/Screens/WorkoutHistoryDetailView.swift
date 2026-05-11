//
//  WorkoutHistoryDetailView.swift
//  LiftBook
//
//  Created by Codex on 26/04/2026.
//

import SwiftData
import SwiftUI

struct WorkoutHistoryDetailView: View {
    let workoutSessionID: UUID

    @Query private var workouts: [WorkoutSession]

    init(workoutSessionID: UUID) {
        self.workoutSessionID = workoutSessionID
        let sessionID = workoutSessionID

        _workouts = Query(filter: #Predicate<WorkoutSession> { workout in
            workout.id == sessionID
        })
    }

    private var workout: WorkoutSession? {
        workouts.first
    }

    var body: some View {
        List {
            if let workout {
                Section {
                    LabeledContent("Source", value: workout.historySourceTitle)
                    LabeledContent("Completed", value: completedAtText(for: workout))
                    LabeledContent("Duration", value: durationText(for: workout))
                }

                Section("Exercises") {
                    if workout.exercises.isEmpty {
                        ContentUnavailableView(
                            "No Exercises",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("This workout has no logged exercises.")
                        )
                    } else {
                        ForEach(sortedExercises(for: workout)) { exercise in
                            WorkoutHistoryExerciseCard(exercise: exercise)
                                .listRowInsets(
                                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                )
                                .listRowBackground(Color.clear)
                        }
                    }
                }
            } else {
                Section {
                    ContentUnavailableView(
                        "Workout Not Found",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("This completed workout may have been deleted.")
                    )
                }
            }
        }
        .navigationTitle(workout?.name ?? "History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sortedExercises(for workout: WorkoutSession) -> [WorkoutSessionExercise] {
        workout.exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    private func completedAtText(for workout: WorkoutSession) -> String {
        guard let endedAt = workout.endedAt else {
            return "Date unavailable"
        }

        return endedAt.formatted(date: .abbreviated, time: .shortened)
    }

    private func durationText(for workout: WorkoutSession) -> String {
        guard let duration = workout.completedDuration else {
            return "Duration unavailable"
        }

        return WorkoutDurationFormatter.string(from: duration)
    }
}

private struct WorkoutHistoryExerciseCard: View {
    let exercise: WorkoutSessionExercise

    private var sortedSets: [WorkoutSet] {
        exercise.sets.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(exercise.exerciseName)
                .font(.title3.weight(.semibold))

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Text("Set #")
                        .frame(maxWidth: .infinity)
                    Text("Reps")
                        .frame(maxWidth: .infinity)
                    Text("Weight")
                        .frame(maxWidth: .infinity)
                    Text("Done")
                        .frame(width: 44)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                ForEach(Array(sortedSets.enumerated()), id: \.element.id) { index, set in
                    WorkoutHistorySetRow(setNumber: index + 1, set: set)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

private struct WorkoutHistorySetRow: View {
    let setNumber: Int
    let set: WorkoutSet

    private var repsText: String {
        guard let reps = set.reps else {
            return "-"
        }

        return String(reps)
    }

    private var weightText: String {
        guard let weight = set.weight else {
            return "-"
        }

        if weight.rounded() == weight {
            return String(Int(weight))
        }

        return String(weight)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(setNumber)")
                .frame(maxWidth: .infinity)

            Text(repsText)
                .frame(maxWidth: .infinity)

            Text(weightText)
                .frame(maxWidth: .infinity)

            Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(set.isCompleted ? .green : .secondary)
                .frame(width: 44, height: 32)
                .accessibilityLabel(set.isCompleted ? "Set logged" : "Set not logged")
        }
        .font(.body)
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        WorkoutHistoryDetailView(workoutSessionID: UUID())
    }
    .modelContainer(
        for: [WorkoutSession.self, WorkoutSessionExercise.self, WorkoutSet.self],
        inMemory: true
    )
}
