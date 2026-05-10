//
//  ActiveWorkoutView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftData
import SwiftUI

struct ActiveWorkoutView: View {
    private static let restDuration: TimeInterval = 90
    private static let restAdjustmentDuration: TimeInterval = 15

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.workoutService) private var workoutService

    let workoutSessionID: UUID
    @Query private var workouts: [WorkoutSession]
    @Query(sort: \Exercise.name) private var exerciseLibrary: [Exercise]

    @State private var isShowingExerciseSelection = false
    @State private var isShowingDiscardConfirmation = false
    @State private var isShowingRoutineUpdatePrompt = false
    @State private var restDeadline: Date?
    @State private var workoutError: ActiveWorkoutError?

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

    private var workoutExerciseIDs: Set<String> {
        guard let workout else {
            return []
        }

        return Set(workout.exercises.map(\.exerciseID))
    }

    var body: some View {
        List {
            if let workout {
                let sortedWorkoutExercises = sortedExercises(for: workout)

                Section {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        ActiveWorkoutElapsedTimerCard(
                            duration: workout.elapsedDuration(at: timeline.date)
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                Section("Exercises") {
                    if sortedWorkoutExercises.isEmpty {
                        LBEmptyStateCard(
                            title: "No Exercises",
                            message: "Add exercises to build this workout.",
                            buttonTitle: "Add Exercise",
                            buttonVariant: .filled,
                            action: showExerciseSelection
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                        LBTipCard(
                            systemImage: "lightbulb",
                            text: "Tip: Add a few movements to get started."
                        )
                            .listRowInsets(
                                EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(sortedWorkoutExercises) { exercise in
                            ActiveWorkoutExerciseCard(
                                exercise: exercise,
                                subtitle: exerciseSubtitle(for: exercise),
                                onDeleteExercise: { deleteExercise(exercise, from: workout) },
                                onAddSet: { addSet(to: exercise) },
                                onDeleteSet: { set in deleteSet(set, from: exercise) },
                                onUpdateSet: { set, reps, weight in
                                    updateSet(set, reps: reps, weight: weight)
                                },
                                onToggleSetCompleted: { set in
                                    toggleCompleted(set)
                                }
                            )
                                .listRowInsets(
                                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                )
                                .listRowBackground(Color.clear)
                        }
                    }
                }

                if !sortedWorkoutExercises.isEmpty {
                    Section {
                        Button(action: showExerciseSelection) {
                            Label("Add Exercise", systemImage: "plus.circle.fill")
                        }
                    }
                }
            } else {
                Section {
                    ContentUnavailableView(
                        "Workout Not Found",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("This workout may have been deleted.")
                    )
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(LBColor.background)
        .navigationTitle(workout?.name ?? "Workout")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Close", action: closeWorkout)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(action: requestFinishWorkout) {
                        Label("Finish Workout", systemImage: "checkmark.circle")
                    }

                    Button(role: .destructive, action: requestDiscardWorkout) {
                        Label("Discard Workout", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Workout options")
            }
        }
        .safeAreaInset(edge: .bottom) {
            restTimerInset
        }
        .task(id: restDeadline) {
            await expireRestTimer(for: restDeadline)
        }
        .fullScreenCover(isPresented: $isShowingExerciseSelection) {
            ExerciseSelectionView(existingExerciseIDs: workoutExerciseIDs) { exercises in
                addExercises(exercises)
            }
        }
        .confirmationDialog(
            "Discard Workout?",
            isPresented: $isShowingDiscardConfirmation,
            titleVisibility: .visible
        ) {
            Button("Discard Workout", role: .destructive, action: discardWorkout)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete the active workout without saving it.")
        }
        .confirmationDialog(
            "Update Routine?",
            isPresented: $isShowingRoutineUpdatePrompt,
            titleVisibility: .visible
        ) {
            Button("Update Routine") {
                finishWorkout(updateSourceRoutine: true)
            }

            Button("Keep Routine As-Is") {
                finishWorkout(updateSourceRoutine: false)
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This workout has different exercises or set counts than the routine it started from.")
        }
        .alert(item: $workoutError) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    @ViewBuilder
    private var restTimerInset: some View {
        if let restDeadline {
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                ActiveWorkoutRestTimerBar(
                    remainingDuration: remainingRestDuration(
                        until: restDeadline,
                        at: timeline.date
                    ),
                    onSubtract: subtractRestTime,
                    onAdd: addRestTime,
                    onSkip: skipRestTimer
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
    }

    private func sortedExercises(for workout: WorkoutSession) -> [WorkoutSessionExercise] {
        workout.sortedExercises
    }

    private func exerciseSubtitle(for workoutExercise: WorkoutSessionExercise) -> String? {
        guard let exercise = exerciseLibrary.first(where: { $0.id == workoutExercise.exerciseID }) else {
            return nil
        }

        if !exercise.primaryMuscles.isEmpty {
            return exercise.primaryMuscles.joined(separator: ", ").capitalized
        }

        return exercise.category.isEmpty ? nil : exercise.category.capitalized
    }

    private func closeWorkout() {
        do {
            try workoutService.save(in: modelContext)
            dismiss()
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Save Workout",
                message: error.localizedDescription
            )
        }
    }

    private func showExerciseSelection() {
        isShowingExerciseSelection = true
    }

    private func addExercises(_ exercises: [Exercise]) {
        guard let workout else {
            return
        }

        do {
            try workoutService.addExercises(exercises, to: workout, in: modelContext)
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Add Exercises",
                message: error.localizedDescription
            )
        }
    }

    private func deleteExercise(_ exercise: WorkoutSessionExercise, from workout: WorkoutSession) {
        do {
            try workoutService.deleteExercise(exercise, from: workout, in: modelContext)
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Delete Exercise",
                message: error.localizedDescription
            )
        }
    }

    private func requestDiscardWorkout() {
        isShowingDiscardConfirmation = true
    }

    private func discardWorkout() {
        guard let workout else {
            dismiss()
            return
        }

        do {
            try workoutService.discard([workout], in: modelContext)
            restDeadline = nil
            dismiss()
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Discard Workout",
                message: error.localizedDescription
            )
        }
    }

    private func requestFinishWorkout() {
        guard let workout else {
            return
        }

        do {
            try workoutService.save(in: modelContext)

            if workoutService.hasSourceRoutineStructureChanges(
                for: workout,
                sourceRoutine: try workoutService.sourceRoutine(for: workout, in: modelContext)
            ) {
                isShowingRoutineUpdatePrompt = true
            } else {
                finishWorkout(updateSourceRoutine: false)
            }
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Finish Workout",
                message: error.localizedDescription
            )
        }
    }

    private func finishWorkout(updateSourceRoutine shouldUpdateSourceRoutine: Bool) {
        guard let workout else {
            dismiss()
            return
        }

        do {
            try workoutService.finish(
                workout,
                updateSourceRoutine: shouldUpdateSourceRoutine,
                in: modelContext
            )
            restDeadline = nil
            dismiss()
        } catch {
            workoutError = ActiveWorkoutError(
                title: shouldUpdateSourceRoutine ? "Could Not Update Routine" : "Could Not Finish Workout",
                message: error.localizedDescription
            )
        }
    }

    private func addSet(to exercise: WorkoutSessionExercise) {
        do {
            try workoutService.addSet(to: exercise, in: modelContext)
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Add Set",
                message: error.localizedDescription
            )
        }
    }

    private func deleteSet(_ set: WorkoutSet, from exercise: WorkoutSessionExercise) {
        do {
            try workoutService.deleteSet(set, from: exercise, in: modelContext)
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Delete Set",
                message: error.localizedDescription
            )
        }
    }

    private func updateSet(_ set: WorkoutSet, reps: Int?, weight: Double?) {
        do {
            try workoutService.updateSet(set, reps: reps, weight: weight, in: modelContext)
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Save Set",
                message: error.localizedDescription
            )
        }
    }

    private func toggleCompleted(_ set: WorkoutSet) {
        let shouldStartRestTimer = !set.isCompleted

        do {
            try workoutService.toggleCompleted(set, in: modelContext)

            if shouldStartRestTimer {
                startRestTimer()
            }
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Save Set",
                message: error.localizedDescription
            )
        }
    }

    private func startRestTimer() {
        restDeadline = Date().addingTimeInterval(Self.restDuration)
    }

    private func skipRestTimer() {
        restDeadline = nil
    }

    private func addRestTime() {
        guard let restDeadline else {
            return
        }

        self.restDeadline = restDeadline.addingTimeInterval(Self.restAdjustmentDuration)
    }

    private func subtractRestTime() {
        guard let restDeadline else {
            return
        }

        let adjustedDeadline = restDeadline.addingTimeInterval(-Self.restAdjustmentDuration)

        if adjustedDeadline <= Date() {
            self.restDeadline = nil
        } else {
            self.restDeadline = adjustedDeadline
        }
    }

    private func remainingRestDuration(until deadline: Date, at date: Date) -> TimeInterval {
        max(0, deadline.timeIntervalSince(date))
    }

    private func expireRestTimer(for deadline: Date?) async {
        guard let deadline else {
            return
        }

        let sleepDuration = max(0, deadline.timeIntervalSinceNow)
        let nanoseconds = UInt64(sleepDuration * 1_000_000_000)

        do {
            try await Task.sleep(nanoseconds: nanoseconds)
        } catch {
            return
        }

        guard !Task.isCancelled, restDeadline == deadline else {
            return
        }

        restDeadline = nil
    }
}

private struct ActiveWorkoutError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private struct ActiveWorkoutElapsedTimerCard: View {
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

private struct ActiveWorkoutRestTimerBar: View {
    @Environment(\.colorScheme) private var colorScheme

    let remainingDuration: TimeInterval
    let onSubtract: () -> Void
    let onAdd: () -> Void
    let onSkip: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "hourglass")
                .font(.headline.weight(.semibold))
                .foregroundStyle(LBColor.workoutStart)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text("Rest")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(WorkoutDurationFormatter.countdownString(from: remainingDuration))
                    .font(.headline.monospacedDigit().weight(.semibold))
            }

            Spacer()

            HStack(spacing: 6) {
                restAdjustmentButton(
                    title: "-15sec",
                    accessibilityLabel: "Subtract 15 seconds",
                    action: onSubtract
                )

                restAdjustmentButton(
                    title: "+15sec",
                    accessibilityLabel: "Add 15 seconds",
                    action: onAdd
                )
            }

            Button(action: onSkip) {
                Label("Skip", systemImage: "forward.end.fill")
            }
            .font(.subheadline.weight(.semibold))
            .buttonStyle(.bordered)
            .tint(LBColor.workoutStart)
            .accessibilityLabel("Skip rest timer")
        }
        .padding(14)
        .background(.regularMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: LBExerciseCardMetrics.cardCornerRadius, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: LBExerciseCardMetrics.cardCornerRadius, style: .continuous)
        )
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.18) : Color.black.opacity(0.12)
    }

    private func restAdjustmentButton(
        title: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .frame(minWidth: 56, minHeight: 34)
        }
        .buttonStyle(.bordered)
        .tint(LBColor.workoutStart)
        .accessibilityLabel(accessibilityLabel)
    }
}

#Preview {
    NavigationStack {
        ActiveWorkoutView(workoutSessionID: UUID())
    }
    .modelContainer(
        for: [Exercise.self, WorkoutSession.self, WorkoutSessionExercise.self, WorkoutSet.self],
        inMemory: true
    )
}
