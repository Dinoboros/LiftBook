//
//  ActiveWorkoutView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftData
import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.workoutService) private var workoutService

    let workoutSessionID: UUID
    @Query private var workouts: [WorkoutSession]

    @State private var isShowingExerciseSelection = false
    @State private var isShowingDiscardConfirmation = false
    @State private var isShowingRoutineUpdatePrompt = false
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

                Section("Exercises") {
                    if sortedWorkoutExercises.isEmpty {
                        ContentUnavailableView(
                            "No Exercises",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("Add exercises to build this workout.")
                        )
                    } else {
                        ForEach(sortedWorkoutExercises) { exercise in
                            ActiveWorkoutExerciseCard(
                                exercise: exercise,
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

                Section {
                    Button(action: showExerciseSelection) {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
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

    private func sortedExercises(for workout: WorkoutSession) -> [WorkoutSessionExercise] {
        workout.sortedExercises
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
        do {
            try workoutService.toggleCompleted(set, in: modelContext)
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Save Set",
                message: error.localizedDescription
            )
        }
    }
}

private struct ActiveWorkoutError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    NavigationStack {
        ActiveWorkoutView(workoutSessionID: UUID())
    }
    .modelContainer(
        for: [WorkoutSession.self, WorkoutSessionExercise.self, WorkoutSet.self],
        inMemory: true
    )
}
