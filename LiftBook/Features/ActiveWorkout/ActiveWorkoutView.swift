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

private struct ActiveWorkoutExerciseCard: View {
    @Environment(\.modelContext) private var modelContext

    let exercise: WorkoutSessionExercise
    let onDeleteExercise: () -> Void

    private var sortedSets: [WorkoutSet] {
        exercise.sets.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        let sortedWorkoutSets = sortedSets
        let canDeleteSet = sortedWorkoutSets.count > 1

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
                    Color.clear
                        .frame(width: 75)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                ForEach(Array(sortedWorkoutSets.enumerated()), id: \.element.id) { index, set in
                    ActiveWorkoutSetRow(
                        setNumber: index + 1,
                        set: set,
                        canDelete: canDeleteSet,
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
    let set: WorkoutSet
    let canDelete: Bool
    let onDelete: () -> Void

    @FocusState private var focusedField: WorkoutSetField?
    @State private var repsText: String
    @State private var weightText: String

    init(
        setNumber: Int,
        set: WorkoutSet,
        canDelete: Bool,
        onDelete: @escaping () -> Void
    ) {
        self.setNumber = setNumber
        self.set = set
        self.canDelete = canDelete
        self.onDelete = onDelete
        _repsText = State(initialValue: Self.text(for: set.reps))
        _weightText = State(initialValue: Self.text(for: set.weight))
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

            TextField("-", text: $repsText)
                .focused($focusedField, equals: .reps)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            TextField("-", text: $weightText)
                .focused($focusedField, equals: .weight)
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
        .onChange(of: focusedField) { oldField, newField in
            guard let oldField, oldField != newField else {
                return
            }

            commitDraft(for: oldField)
        }
        .onChange(of: set.reps) { _, newValue in
            guard focusedField != .reps else {
                return
            }

            repsText = Self.text(for: newValue)
        }
        .onChange(of: set.weight) { _, newValue in
            guard focusedField != .weight else {
                return
            }

            weightText = Self.text(for: newValue)
        }
        .onDisappear(perform: commitDrafts)
    }

    private func toggleCompleted() {
        set.isCompleted.toggle()
        saveSet()
    }

    private func commitDraft(for field: WorkoutSetField) {
        let didChange: Bool

        switch field {
        case .reps:
            didChange = applyRepsDraft()
        case .weight:
            didChange = applyWeightDraft()
        }

        if didChange {
            saveSet()
        }
    }

    private func commitDrafts() {
        let didChangeReps = applyRepsDraft()
        let didChangeWeight = applyWeightDraft()

        if didChangeReps || didChangeWeight {
            saveSet()
        }
    }

    private func applyRepsDraft() -> Bool {
        let newValue = Self.repsValue(from: repsText)
        let didChange = set.reps != newValue

        if didChange {
            set.reps = newValue
        }

        repsText = Self.text(for: set.reps)
        return didChange
    }

    private func applyWeightDraft() -> Bool {
        let newValue = Self.weightValue(from: weightText)
        let didChange = set.weight != newValue

        if didChange {
            set.weight = newValue
        }

        weightText = Self.text(for: set.weight)
        return didChange
    }

    private func saveSet() {
        try? modelContext.save()
    }

    private static func repsValue(from text: String) -> Int? {
        let trimmedValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : Int(trimmedValue)
    }

    private static func weightValue(from text: String) -> Double? {
        let trimmedValue = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !trimmedValue.isEmpty, let weight = Double(trimmedValue), weight.isFinite else {
            return nil
        }

        return weight
    }

    private static func text(for reps: Int?) -> String {
        guard let reps else {
            return ""
        }

        return String(reps)
    }

    private static func text(for weight: Double?) -> String {
        guard let weight else {
            return ""
        }

        if weight.rounded() == weight {
            return String(Int(weight))
        }

        return String(weight)
    }
}

private enum WorkoutSetField: Hashable {
    case reps
    case weight
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
