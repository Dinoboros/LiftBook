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
    @Query(sort: \RoutineTemplate.updatedAt, order: .reverse) private var routines: [RoutineTemplate]

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
                Section("Exercises") {
                    if workout.exercises.isEmpty {
                        ContentUnavailableView(
                            "No Exercises",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("Add exercises to build this workout.")
                        )
                    } else {
                        ForEach(sortedExercises(for: workout)) { exercise in
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

        if hasSourceRoutineStructureChanges(for: workout) {
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

        if shouldUpdateSourceRoutine {
            updateSourceRoutine(from: workout)
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

    private func hasSourceRoutineStructureChanges(for workout: WorkoutSession) -> Bool {
        guard let sourceRoutine = sourceRoutine(for: workout) else {
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

    private func sourceRoutine(for workout: WorkoutSession) -> RoutineTemplate? {
        guard let sourceRoutineTemplateID = workout.sourceRoutineTemplateID else {
            return nil
        }

        return routines.first { $0.id == sourceRoutineTemplateID }
    }

    private func updateSourceRoutine(from workout: WorkoutSession) {
        guard let sourceRoutine = sourceRoutine(for: workout) else {
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

private struct ActiveWorkoutExerciseCard: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var exercise: WorkoutSessionExercise
    let onDeleteExercise: () -> Void

    private var sortedSets: [WorkoutSet] {
        exercise.sets.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                Text(exercise.exerciseName)
                    .font(.title3.weight(.semibold))

                Spacer()

                Menu {
                    Button(role: .destructive, action: onDeleteExercise) {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Exercise options")
            }

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
                    Color.clear
                        .frame(width: 32)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                ForEach(Array(sortedSets.enumerated()), id: \.element.id) { index, set in
                    ActiveWorkoutSetRow(
                        setNumber: index + 1,
                        set: set,
                        canDelete: sortedSets.count > 1,
                        onDelete: { deleteSet(set) }
                    )
                }
            }

            Button(action: addSet) {
                Label("Add set", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
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

    private func addSet() {
        let nextSortOrder = (exercise.sets.map(\.sortOrder).max() ?? -1) + 1
        let workoutSet = WorkoutSet(sortOrder: nextSortOrder)
        modelContext.insert(workoutSet)
        exercise.sets.append(workoutSet)
        saveChanges()
    }

    private func deleteSet(_ set: WorkoutSet) {
        guard exercise.sets.count > 1 else {
            return
        }

        exercise.sets.removeAll { $0.id == set.id }
        modelContext.delete(set)
        normalizeSetSortOrders()
        saveChanges()
    }

    private func normalizeSetSortOrders() {
        for (index, set) in sortedSets.enumerated() {
            set.sortOrder = index
        }
    }

    private func saveChanges() {
        try? modelContext.save()
    }
}

private struct ActiveWorkoutSetRow: View {
    @Environment(\.modelContext) private var modelContext

    let setNumber: Int
    @Bindable var set: WorkoutSet
    let canDelete: Bool
    let onDelete: () -> Void

    private var repsText: Binding<String> {
        Binding(
            get: {
                guard let reps = set.reps else {
                    return ""
                }

                return String(reps)
            },
            set: { newValue in
                let trimmedValue = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                set.reps = trimmedValue.isEmpty ? nil : Int(trimmedValue)
                saveSet()
            }
        )
    }

    private var weightText: Binding<String> {
        Binding(
            get: {
                guard let weight = set.weight else {
                    return ""
                }

                if weight.rounded() == weight {
                    return String(Int(weight))
                }

                return String(weight)
            },
            set: { newValue in
                let trimmedValue = newValue
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: ",", with: ".")

                set.weight = trimmedValue.isEmpty ? nil : Double(trimmedValue)
                saveSet()
            }
        )
    }

    private var rowGradientColors: [Color] {
        if setNumber.isMultiple(of: 2) {
            return [
                .teal.opacity(0.14),
                .cyan.opacity(0.07)
            ]
        }

        return [
            .indigo.opacity(0.13),
            .blue.opacity(0.06)
        ]
    }

    private var rowGradient: LinearGradient {
        LinearGradient(
            colors: rowGradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(setNumber)")
                .frame(maxWidth: .infinity)

            TextField("-", text: repsText)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            TextField("-", text: weightText)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Button(action: toggleCompleted) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(set.isCompleted ? .green : .secondary)
                    .frame(width: 44, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(set.isCompleted ? "Set logged" : "Set not logged")

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.body.weight(.semibold))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .opacity(canDelete ? 1 : 0)
            .disabled(!canDelete)
            .accessibilityLabel("Delete set \(setNumber)")
        }
        .font(.body)
        .padding(.vertical, 4)
        .background {
            Color(.secondarySystemGroupedBackground)
            rowGradient
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private func toggleCompleted() {
        set.isCompleted.toggle()
        saveSet()
    }

    private func saveSet() {
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
