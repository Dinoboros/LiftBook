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
                                onDeleteExercise: { deleteExercise(exercise, from: workout) }
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
        .appKeyboardDismissal()
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
        .onDisappear(perform: saveWorkout)
    }

    private func sortedExercises(for workout: WorkoutSession) -> [WorkoutSessionExercise] {
        workout.exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    private func sortedExercises(for routine: RoutineTemplate) -> [RoutineTemplateExercise] {
        routine.exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    private func closeWorkout() {
        saveWorkout()
        dismiss()
    }

    private func showExerciseSelection() {
        isShowingExerciseSelection = true
    }

    private func addExercises(_ exercises: [Exercise]) {
        guard let workout else {
            return
        }

        let existingExerciseIDs = Set(workout.exercises.map(\.exerciseID))
        let firstSortOrder = (workout.exercises.map(\.sortOrder).max() ?? -1) + 1
        let newExercises = exercises.filter { !existingExerciseIDs.contains($0.id) }

        for (index, exercise) in newExercises.enumerated() {
            let workoutExercise = WorkoutSessionExercise(
                exerciseID: exercise.id,
                exerciseName: exercise.name,
                sortOrder: firstSortOrder + index
            )
            modelContext.insert(workoutExercise)
            workout.exercises.append(workoutExercise)

            for setIndex in 0..<3 {
                let workoutSet = WorkoutSet(sortOrder: setIndex)
                modelContext.insert(workoutSet)
                workoutExercise.sets.append(workoutSet)
            }
        }

        saveWorkout()
    }

    private func deleteExercise(_ exercise: WorkoutSessionExercise, from workout: WorkoutSession) {
        workout.exercises.removeAll { $0.id == exercise.id }
        modelContext.delete(exercise)
        normalizeExerciseSortOrders(for: workout)
        saveWorkout()
    }

    private func normalizeExerciseSortOrders(for workout: WorkoutSession) {
        for (index, exercise) in sortedExercises(for: workout).enumerated() {
            exercise.sortOrder = index
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

        modelContext.delete(workout)

        do {
            try modelContext.save()
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

        saveWorkout()

        do {
            if hasSourceRoutineStructureChanges(for: workout, sourceRoutine: try sourceRoutine(for: workout)) {
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

        if shouldUpdateSourceRoutine {
            do {
                try updateSourceRoutine(from: workout)
            } catch {
                workoutError = ActiveWorkoutError(
                    title: "Could Not Update Routine",
                    message: error.localizedDescription
                )
                return
            }
        }

        workout.endedAt = .now

        do {
            try modelContext.save()
            dismiss()
        } catch {
            workoutError = ActiveWorkoutError(
                title: "Could Not Finish Workout",
                message: error.localizedDescription
            )
        }
    }

    private func hasSourceRoutineStructureChanges(
        for workout: WorkoutSession,
        sourceRoutine: RoutineTemplate?
    ) -> Bool {
        guard let sourceRoutine else {
            return false
        }

        let workoutStructure = sortedExercises(for: workout).map {
            WorkoutStructureItem(exerciseID: $0.exerciseID, setCount: max($0.sets.count, 1))
        }
        let routineStructure = sortedExercises(for: sourceRoutine).map {
            WorkoutStructureItem(exerciseID: $0.exerciseID, setCount: max($0.targetSets, 1))
        }

        return workoutStructure != routineStructure
    }

    private func sourceRoutine(for workout: WorkoutSession) throws -> RoutineTemplate? {
        guard let sourceRoutineTemplateID = workout.sourceRoutineTemplateID else {
            return nil
        }

        var descriptor = FetchDescriptor<RoutineTemplate>(
            predicate: #Predicate { routine in
                routine.id == sourceRoutineTemplateID
            }
        )
        descriptor.fetchLimit = 1

        return try modelContext.fetch(descriptor).first
    }

    private func updateSourceRoutine(from workout: WorkoutSession) throws {
        guard let sourceRoutine = try sourceRoutine(for: workout) else {
            return
        }

        for exercise in sourceRoutine.exercises {
            modelContext.delete(exercise)
        }
        sourceRoutine.exercises.removeAll()

        for (index, workoutExercise) in sortedExercises(for: workout).enumerated() {
            let routineExercise = RoutineTemplateExercise(
                exerciseID: workoutExercise.exerciseID,
                exerciseName: workoutExercise.exerciseName,
                sortOrder: index,
                targetSets: max(workoutExercise.sets.count, 1)
            )
            modelContext.insert(routineExercise)
            sourceRoutine.exercises.append(routineExercise)
        }

        sourceRoutine.updatedAt = .now
    }

    private func saveWorkout() {
        try? modelContext.save()
    }
}

private struct WorkoutStructureItem: Equatable {
    let exerciseID: String
    let setCount: Int
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
