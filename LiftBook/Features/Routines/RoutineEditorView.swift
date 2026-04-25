//
//  RoutineEditorView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftData
import SwiftUI

struct RoutineEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var routineName = ""
    @State private var selectedExercises: [RoutineExerciseDraft] = []
    @State private var isShowingExerciseSelection = false
    @State private var saveError: RoutineSaveError?

    private var trimmedRoutineName: String {
        routineName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var selectedExerciseIDs: Set<String> {
        Set(selectedExercises.map(\.exerciseID))
    }

    private var canSave: Bool {
        !trimmedRoutineName.isEmpty && !selectedExercises.isEmpty
    }

    var body: some View {
        List {
            Section("Name") {
                TextField("Routine name", text: $routineName)
                    .textInputAutocapitalization(.words)
            }

            Section("Exercises") {
                if selectedExercises.isEmpty {
                    ContentUnavailableView(
                        "No Exercises",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Add exercises to build this routine.")
                    )
                } else {
                    ForEach($selectedExercises) { exercise in
                        RoutineExerciseDraftCard(
                            exercise: exercise,
                            onDelete: { deleteExercise(exercise.wrappedValue) }
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
        }
        .navigationTitle("Create Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: saveRoutine)
                    .disabled(!canSave)
            }
        }
        .fullScreenCover(isPresented: $isShowingExerciseSelection) {
            ExerciseSelectionView(existingExerciseIDs: selectedExerciseIDs) { exercises in
                addExercises(exercises)
            }
        }
        .alert(item: $saveError) { error in
            Alert(
                title: Text("Could Not Save Routine"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func showExerciseSelection() {
        isShowingExerciseSelection = true
    }

    @MainActor
    private func addExercises(_ exercises: [Exercise]) {
        let newDrafts = exercises
            .filter { !selectedExerciseIDs.contains($0.id) }
            .map(RoutineExerciseDraft.init)

        selectedExercises.append(contentsOf: newDrafts)
    }

    private func deleteExercise(_ exercise: RoutineExerciseDraft) {
        selectedExercises.removeAll { $0.id == exercise.id }
    }

    private func saveRoutine() {
        guard canSave else {
            return
        }

        let routine = RoutineTemplate(name: trimmedRoutineName)
        modelContext.insert(routine)

        for (index, exercise) in selectedExercises.enumerated() {
            let routineExercise = RoutineTemplateExercise(
                exerciseID: exercise.exerciseID,
                exerciseName: exercise.exerciseName,
                sortOrder: index,
                targetSets: exercise.targetSets
            )

            modelContext.insert(routineExercise)
            routine.exercises.append(routineExercise)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            saveError = RoutineSaveError(message: error.localizedDescription)
        }
    }
}

private struct RoutineExerciseDraft: Identifiable, Equatable {
    let exerciseID: String
    let exerciseName: String
    let category: String
    let primaryMuscles: [String]
    var sets: [RoutineSetDraft]

    var id: String {
        exerciseID
    }

    var targetSets: Int {
        sets.count
    }

    init(exercise: Exercise) {
        exerciseID = exercise.id
        exerciseName = exercise.name
        category = exercise.category
        primaryMuscles = exercise.primaryMuscles
        sets = [
            RoutineSetDraft(),
            RoutineSetDraft(),
            RoutineSetDraft()
        ]
    }

    var subtitle: String {
        if !primaryMuscles.isEmpty {
            return primaryMuscles.joined(separator: ", ").capitalized
        }

        return category.capitalized
    }
}

private struct RoutineSetDraft: Identifiable, Equatable {
    let id = UUID()
    var reps = ""
    var weight = ""
}

private struct RoutineExerciseDraftCard: View {
    @Binding var exercise: RoutineExerciseDraft
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exerciseName)
                        .font(.title3.weight(.semibold))

                    if !exercise.subtitle.isEmpty {
                        Text(exercise.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Menu {
                    Button(role: .destructive, action: onDelete) {
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
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    RoutineSetDraftRow(
                        setNumber: index + 1,
                        set: $exercise.sets[index],
                        canDelete: exercise.sets.count > 1,
                        onDelete: { deleteSet(id: set.id) }
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
        exercise.sets.append(RoutineSetDraft())
    }

    private func deleteSet(id: UUID) {
        guard exercise.sets.count > 1 else {
            return
        }

        exercise.sets.removeAll { $0.id == id }
    }
}

private struct RoutineSetDraftRow: View {
    let setNumber: Int
    @Binding var set: RoutineSetDraft
    let canDelete: Bool
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0

    private let deleteButtonWidth: CGFloat = 72
    private let revealThreshold: CGFloat = 24

    private var isDeleteRevealed: Bool {
        offset < 0
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
        return LinearGradient(
            colors: rowGradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: deleteButtonWidth)
                    .frame(maxHeight: .infinity)
                    .background(.red)
            }
            .buttonStyle(.plain)
            .opacity(canDelete && isDeleteRevealed ? 1 : 0)
            .accessibilityLabel("Delete set \(setNumber)")

            HStack(spacing: 12) {
                Text("\(setNumber)")
                    .frame(maxWidth: .infinity)

                TextField("-", text: $set.reps)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                TextField("-", text: $set.weight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .font(.body)
            .padding(.vertical, 4)
            .background {
                Color(.secondarySystemGroupedBackground)
                rowGradient
            }
            .offset(x: canDelete ? offset : 0)
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        guard canDelete else {
                            return
                        }

                        offset = max(-deleteButtonWidth, min(0, value.translation.width))
                    }
                    .onEnded { value in
                        guard canDelete else {
                            return
                        }

                        if value.translation.width < -revealThreshold {
                            offset = -deleteButtonWidth
                        } else {
                            offset = 0
                        }
                    }
            )
            .animation(.snappy(duration: 0.2), value: offset)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

private struct RoutineSaveError: Identifiable {
    let id = UUID()
    let message: String
}

#Preview {
    NavigationStack {
        RoutineEditorView()
    }
    .modelContainer(
        for: [Exercise.self, RoutineTemplate.self, RoutineTemplateExercise.self],
        inMemory: true
    )
}
