//
//  ActiveWorkoutView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftData
import SwiftUI

struct ActiveWorkoutView: View {
    private static let restTimerBottomContentMargin: CGFloat = 104

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.workoutService) private var workoutService
    @Environment(\.restTimerNotificationService) private var restTimerNotificationService
    @Environment(\.restTimerNotificationCoordinator) private var restTimerNotificationCoordinator
    @Environment(\.scenePhase) private var scenePhase

    let workoutSessionID: UUID
    @Query private var workouts: [WorkoutSession]
    @Query(sort: \Exercise.name) private var exerciseLibrary: [Exercise]

    @State private var isShowingExerciseSelection = false
    @State private var isShowingDiscardConfirmation = false
    @State private var isShowingEmptyWorkoutDiscardConfirmation = false
    @State private var isShowingUnloggedSetsConfirmation = false
    @State private var isShowingRoutineUpdatePrompt = false
    @State private var workoutError: ActiveWorkoutError?
    @State private var restTimerNotificationTask: Task<Void, Never>?
    @AppStorage(LBSettingsKeys.defaultRestTimerDurationSeconds) private var defaultRestTimerDurationSeconds = RestTimerDuration.defaultValue.rawValue

    private let restTimer = ActiveWorkoutRestTimerStore()

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

    private var defaultRestTimerDuration: RestTimerDuration {
        RestTimerDuration(seconds: defaultRestTimerDurationSeconds)
    }

    private var exerciseLibraryByID: [String: Exercise] {
        Dictionary(uniqueKeysWithValues: exerciseLibrary.map { ($0.id, $0) })
    }

    var body: some View {
        List {
            if let workout {
                let sortedWorkoutExercises = sortedExercises(for: workout)

                Section {
                    TimelineView(.periodic(from: .now, by: 1)) { timeline in
                        ActiveWorkoutStatsStrip(
                            duration: workout.elapsedDuration(at: timeline.date),
                            remainingRestDuration: workout.remainingRestDuration(at: timeline.date)
                        )
                    }
                    .listRowInsets(LBCardLayout.listRowInsets(top: 8, bottom: 8))
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
                        .listRowInsets(LBCardLayout.listRowInsets(top: 8, bottom: 8))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                        LBTipCard(
                            systemImage: "lightbulb",
                            text: "Tip: Add a few movements to get started."
                        )
                            .listRowInsets(
                                LBCardLayout.listRowInsets(top: 8, bottom: 8)
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    } else {
                        let exerciseLookup = exerciseLibraryByID

                        ForEach(sortedWorkoutExercises) { exercise in
                            ActiveWorkoutExerciseCard(
                                exercise: exercise,
                                subtitle: exerciseSubtitle(
                                    for: exercise,
                                    in: exerciseLookup
                                ),
                                onDeleteExercise: { deleteExercise(exercise, from: workout) },
                                onAddSet: { addSet(to: exercise) },
                                onDeleteSet: { set in deleteSet(set, from: exercise) },
                                onUpdateSet: { set, reps, weight in
                                    updateSet(set, reps: reps, weight: weight)
                                },
                                onToggleSetCompleted: { set in
                                    toggleCompleted(set, in: workout)
                                }
                            )
                                .listRowInsets(
                                    LBCardLayout.listRowInsets(top: 8, bottom: 8)
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
        .contentMargins(
            .bottom,
            workout?.remainingRestDuration() == nil ? 0 : Self.restTimerBottomContentMargin,
            for: .scrollContent
        )
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
        .lbKeyboardDismissToolbar()
        .overlay(alignment: .bottom) {
            restTimerOverlay
        }
        .task(id: workout?.restTimerDeadline) {
            guard let workout, let restTimerDeadline = workout.restTimerDeadline else {
                return
            }

            await expireRestTimer(for: restTimerDeadline)
        }
        .onAppear {
            restTimerNotificationCoordinator.setActiveWorkoutVisible(
                workoutSessionID,
                isCovered: isShowingExerciseSelection
            )
            clearExpiredRestTimerIfNeeded()
            handleNotificationPresentationRequest(
                restTimerNotificationCoordinator.requestedWorkoutSessionID
            )
        }
        .onDisappear {
            restTimerNotificationCoordinator.clearActiveWorkoutVisible(workoutSessionID)
        }
        .onChange(of: isShowingExerciseSelection) { _, isShowingExerciseSelection in
            restTimerNotificationCoordinator.setActiveWorkoutCovered(
                isShowingExerciseSelection,
                for: workoutSessionID
            )
        }
        .onChange(of: restTimerNotificationCoordinator.requestedWorkoutSessionID) { _, request in
            handleNotificationPresentationRequest(request)
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else {
                return
            }

            clearExpiredRestTimerIfNeeded()
        }
        .fullScreenCover(isPresented: $isShowingExerciseSelection) {
            ExerciseSelectionView(existingExerciseIDs: workoutExerciseIDs) { exercises in
                addExercises(exercises)
            }
        }
        .alert(
            "Discard Workout?",
            isPresented: $isShowingDiscardConfirmation,
        ) {
            Button("Discard Workout", role: .destructive, action: discardWorkout)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete the active workout without saving it.")
        }
        .alert(
            "Discard Workout?",
            isPresented: $isShowingEmptyWorkoutDiscardConfirmation,
        ) {
            Button("Discard Workout", role: .destructive, action: discardWorkout)
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("No sets were logged. Discard this workout? It will not be saved to history.")
        }
        .alert(
            "Finish Workout?",
            isPresented: $isShowingUnloggedSetsConfirmation,
        ) {
            Button("Finish Workout", action: continueFinishWorkout)
            Button("Keep Editing", role: .cancel) {}
        } message: {
            Text("Some sets have values but are not logged. Finish anyway? Unlogged sets will not be saved to history.")
        }
        .alert(
            "Update Routine?",
            isPresented: $isShowingRoutineUpdatePrompt,
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
    private var restTimerOverlay: some View {
        if let workout,
           let restDeadline = workout.restTimerDeadline,
           workout.remainingRestDuration() != nil {
            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                ActiveWorkoutRestTimerBar(
                    remainingDuration: restTimer.remainingDuration(
                        until: restDeadline,
                        at: timeline.date
                    ),
                    onSubtract: { subtractRestTime(for: workout) },
                    onAdd: { addRestTime(for: workout) },
                    onSkip: { skipRestTimer(for: workout) }
                )
                .padding(.horizontal, LBCardLayout.scrollHorizontalPadding)
                .padding(.vertical, 10)
            }
        }
    }

    private func sortedExercises(for workout: WorkoutSession) -> [WorkoutSessionExercise] {
        workout.sortedExercises
    }

    private func exerciseSubtitle(
        for workoutExercise: WorkoutSessionExercise,
        in exerciseLibraryByID: [String: Exercise]
    ) -> String? {
        guard let exercise = exerciseLibraryByID[workoutExercise.exerciseID] else {
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
            cancelRestTimerNotification(for: workout.id)
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

            guard workoutService.hasCompletedSets(for: workout) else {
                isShowingEmptyWorkoutDiscardConfirmation = true
                return
            }

            guard !workoutService.hasUncompletedFilledSets(for: workout) else {
                isShowingUnloggedSetsConfirmation = true
                return
            }

            try continueFinishWorkoutAfterPreflight()
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Finish Workout",
                message: error.localizedDescription
            )
        }
    }

    private func continueFinishWorkout() {
        do {
            try continueFinishWorkoutAfterPreflight()
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Finish Workout",
                message: error.localizedDescription
            )
        }
    }

    private func continueFinishWorkoutAfterPreflight() throws {
        guard let workout else {
            dismiss()
            return
        }

        if workoutService.hasSourceRoutineStructureChanges(
            for: workout,
            sourceRoutine: try workoutService.sourceRoutine(for: workout, in: modelContext)
        ) {
            isShowingRoutineUpdatePrompt = true
        } else {
            finishWorkout(updateSourceRoutine: false)
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
            cancelRestTimerNotification(for: workout.id)
            dismiss()
        } catch WorkoutServiceError.noCompletedSets {
            isShowingEmptyWorkoutDiscardConfirmation = true
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

    private func toggleCompleted(_ set: WorkoutSet, in workout: WorkoutSession) {
        let wasCompleted = set.isCompleted

        do {
            try workoutService.toggleCompleted(set, in: modelContext)

            if !wasCompleted && set.isCompleted {
                setRestTimerDeadline(
                    restTimer.startDeadline(
                        restDuration: defaultRestTimerDuration.timeInterval
                    ),
                    for: workout
                )
            }
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Save Set",
                message: error.localizedDescription
            )
        }
    }

    private func addRestTime(for workout: WorkoutSession) {
        guard let restTimerDeadline = workout.restTimerDeadline else {
            return
        }

        setRestTimerDeadline(
            restTimer.deadlineByAddingTime(to: restTimerDeadline),
            for: workout
        )
    }

    private func subtractRestTime(for workout: WorkoutSession) {
        guard let restTimerDeadline = workout.restTimerDeadline else {
            return
        }

        setRestTimerDeadline(
            restTimer.deadlineBySubtractingTime(from: restTimerDeadline),
            for: workout
        )
    }

    private func skipRestTimer(for workout: WorkoutSession) {
        setRestTimerDeadline(nil, for: workout)
    }

    @MainActor
    private func expireRestTimer(for restTimerDeadline: Date) async {
        guard await restTimer.waitUntilExpired(for: restTimerDeadline),
              let workout,
              workout.restTimerDeadline == restTimerDeadline else {
            return
        }

        clearExpiredRestTimerIfNeeded()
    }

    private func clearExpiredRestTimerIfNeeded() {
        guard let workout else {
            return
        }

        do {
            if try workoutService.clearExpiredRestTimer(for: workout, in: modelContext) {
                cancelRestTimerNotification(for: workout.id)
            }
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Save Rest Timer",
                message: error.localizedDescription
            )
        }
    }

    private func setRestTimerDeadline(_ deadline: Date?, for workout: WorkoutSession) {
        do {
            try workoutService.setRestTimerDeadline(deadline, for: workout, in: modelContext)

            if let deadline {
                scheduleRestTimerNotification(for: workout, deadline: deadline)
            } else {
                cancelRestTimerNotification(for: workout.id)
            }
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Save Rest Timer",
                message: error.localizedDescription
            )
        }
    }

    private func scheduleRestTimerNotification(for workout: WorkoutSession, deadline: Date) {
        let notificationService = restTimerNotificationService
        let workoutID = workout.id
        let workoutName = workout.name

        restTimerNotificationTask?.cancel()
        restTimerNotificationTask = Task {
            _ = try? await notificationService.scheduleRestTimerNotification(
                workoutID: workoutID,
                workoutName: workoutName,
                deadline: deadline
            )
        }
    }

    private func cancelRestTimerNotification(for workoutID: UUID) {
        restTimerNotificationTask?.cancel()
        restTimerNotificationTask = nil
        restTimerNotificationService.cancelRestTimerNotification(for: workoutID)
    }

    private func handleNotificationPresentationRequest(_ request: UUID?) {
        guard request == workoutSessionID else {
            return
        }

        isShowingExerciseSelection = false
        restTimerNotificationCoordinator.consumeWorkoutPresentationRequest(workoutSessionID)
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
