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
                    ForEach(selectedExercises) { exercise in
                        RoutineExerciseDraftRow(
                            exercise: exercise,
                            onDelete: { deleteExercise(exercise) }
                        )
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
    var targetSets: Int

    var id: String {
        exerciseID
    }

    init(exercise: Exercise) {
        exerciseID = exercise.id
        exerciseName = exercise.name
        category = exercise.category
        primaryMuscles = exercise.primaryMuscles
        targetSets = 3
    }

    var subtitle: String {
        if !primaryMuscles.isEmpty {
            return primaryMuscles.joined(separator: ", ").capitalized
        }

        return category.capitalized
    }
}

private struct RoutineExerciseDraftRow: View {
    let exercise: RoutineExerciseDraft
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.exerciseName)
                    .font(.body)

                if !exercise.subtitle.isEmpty {
                    Text(exercise.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("\(exercise.targetSets) sets")
                .font(.caption)
                .foregroundStyle(.secondary)

            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Exercise", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
            .accessibilityLabel("Exercise options")
        }
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
