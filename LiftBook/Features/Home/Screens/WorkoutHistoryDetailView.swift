//
//  WorkoutHistoryDetailView.swift
//  LiftBook
//
//  Created by Codex on 26/04/2026.
//

import SwiftData
import SwiftUI

struct WorkoutHistoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.workoutService) private var workoutService

    let workoutSessionID: UUID

    @Query private var workouts: [WorkoutSession]
    @Query(sort: \Exercise.name) private var exerciseLibrary: [Exercise]

    @State private var isShowingDeleteConfirmation = false
    @State private var historyError: HomeError?

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
        Group {
            if let workout {
                workoutContent(for: workout)
            } else {
                ContentUnavailableView(
                    "Workout Not Found",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("This completed workout may have been deleted.")
                )
            }
        }
        .navigationTitle(workout?.name ?? "History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if workout != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive, action: requestDeleteWorkout) {
                        Image(systemName: "trash")
                    }
                    .accessibilityLabel("Delete Workout")
                }
            }
        }
        .confirmationDialog(
            "Delete Workout?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Workout", role: .destructive, action: deleteWorkout)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(deleteConfirmationMessage)
        }
        .alert(item: $historyError) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func workoutContent(for workout: WorkoutSession) -> some View {
        List {
            Section {
                WorkoutHistoryDetailSummaryCard(
                    title: workout.name,
                    summary: HomeWorkoutFormatter.exerciseSummary(for: workout),
                    sourceText: workout.historySourceTitle,
                    sourceSystemImage: workout.historySourceSystemImage,
                    completedAtText: completedAtText(for: workout),
                    durationText: durationText(for: workout)
                )
                .listRowInsets(
                    LBCardLayout.listRowInsets(top: 8, bottom: 14)
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            Section("Exercises") {
                if completedExercises(for: workout).isEmpty {
                    ContentUnavailableView(
                        "No Completed Sets",
                        systemImage: "checkmark.circle",
                        description: Text("This workout has no completed sets.")
                    )
                } else {
                    ForEach(completedExercises(for: workout)) { exercise in
                        WorkoutHistoryExerciseCard(
                            exercise: exercise,
                            subtitle: RoutineDetailFormatter.exerciseSubtitle(
                                for: exercise,
                                in: exerciseLibrary
                            )
                        )
                        .listRowInsets(
                            LBCardLayout.listRowInsets(top: 12, bottom: 12)
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(LBColor.background)
    }

    private func completedExercises(for workout: WorkoutSession) -> [WorkoutSessionExercise] {
        workout.sortedExercises.filter { exercise in
            exercise.sortedSets.contains { $0.isCompleted }
        }
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

    private var deleteConfirmationMessage: String {
        guard let workout else {
            return "This workout will be permanently deleted."
        }

        return "This will permanently delete \"\(workout.name)\"."
    }

    private func requestDeleteWorkout() {
        isShowingDeleteConfirmation = true
    }

    private func deleteWorkout() {
        guard let workout else {
            dismiss()
            return
        }

        do {
            try workoutService.delete(workout, in: modelContext)
            dismiss()
        } catch {
            historyError = HomeError(
                title: "Could Not Delete Workout",
                message: error.localizedDescription
            )
        }
    }
}

private struct WorkoutHistoryDetailSummaryCard: View {
    let title: String
    let summary: String
    let sourceText: String
    let sourceSystemImage: String
    let completedAtText: String
    let durationText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    sourceChip
                    completedAtChip
                    durationChip
                    Spacer(minLength: 0)
                }

                VStack(alignment: .leading, spacing: 8) {
                    sourceChip
                    completedAtChip
                    durationChip
                }
            }
        }
        .padding(18)
        .lbCardSurface()
    }

    private var sourceChip: some View {
        LBInfoChip(
            systemImage: sourceSystemImage,
            text: sourceText,
            tint: LBColor.workoutStart
        )
    }

    private var completedAtChip: some View {
        LBInfoChip(
            systemImage: "calendar",
            text: completedAtText,
            tint: Color.secondary
        )
    }

    private var durationChip: some View {
        LBInfoChip(
            systemImage: "timer",
            text: durationText,
            tint: Color.secondary
        )
    }
}

private struct WorkoutHistoryExerciseCard: View {
    let exercise: WorkoutSessionExercise
    let subtitle: String?

    private var completedSets: [WorkoutSet] {
        exercise.sortedSets.filter { $0.isCompleted }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.exerciseName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 8) {
                LBExerciseSetTableHeader(showsCompletionColumn: false)

                ForEach(completedSets) { set in
                    WorkoutHistorySetRow(
                        setNumber: set.sortOrder + 1,
                        set: set
                    )
                }
            }
        }
        .lbExpandedExerciseCardSurface()
    }
}

private struct WorkoutHistorySetRow: View {
    let setNumber: Int
    let set: WorkoutSet

    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue

    private var preferredWeightUnit: WeightUnit {
        WeightUnit(rawValue: preferredWeightUnitRawValue) ?? .kilograms
    }

    private var repsText: String {
        guard let reps = set.reps else {
            return "-"
        }

        return String(reps)
    }

    private var weightText: String {
        LBWeightFormatter.displayText(forKilograms: set.weight, unit: preferredWeightUnit)
    }

    var body: some View {
        HStack(spacing: 0) {
            Text("\(setNumber)")
                .frame(width: LBExerciseCardMetrics.setNumberWidth)

            LBExerciseSetColumnDivider()

            Text(repsText)
                .frame(maxWidth: .infinity)

            LBExerciseSetColumnDivider()

            Text(weightText)
                .frame(maxWidth: .infinity)
        }
        .font(.body)
        .frame(maxWidth: .infinity, minHeight: LBExerciseCardMetrics.rowHeight)
        .background {
            LBExerciseSetRowBackground(isCompleted: true)
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                style: .continuous
            )
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        WorkoutHistoryDetailView(workoutSessionID: UUID())
    }
    .modelContainer(
        for: [Exercise.self, WorkoutSession.self, WorkoutSessionExercise.self, WorkoutSet.self],
        inMemory: true
    )
}
