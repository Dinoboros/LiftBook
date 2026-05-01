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
    @Environment(\.routineService) private var routineService

    @State private var routineDraft = RoutineDraft()
    @State private var isShowingExerciseSelection = false
    @State private var saveError: RoutineSaveError?

    private var selectedExerciseIDs: Set<String> {
        routineDraft.exerciseIDs
    }

    private var canSave: Bool {
        routineDraft.canSave
    }

    var body: some View {
        List {
            Section("Name") {
                TextField("Routine name", text: $routineDraft.name)
                    .textInputAutocapitalization(.words)
            }

            Section("Exercises") {
                if routineDraft.exercises.isEmpty {
                    ContentUnavailableView(
                        "No Exercises",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Add exercises to build this routine.")
                    )
                } else {
                    ForEach($routineDraft.exercises) { exercise in
                        RoutineDraftExerciseCard(
                            exercise: exercise,
                            showsSubtitle: true,
                            showsSetInputs: true,
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
        routineDraft.addExercises(exercises)
    }

    private func deleteExercise(_ exercise: RoutineExerciseDraft) {
        routineDraft.deleteExercise(exercise)
    }

    private func saveRoutine() {
        guard canSave else {
            return
        }

        do {
            try routineService.create(from: routineDraft, in: modelContext)
            dismiss()
        } catch {
            saveError = RoutineSaveError(message: error.localizedDescription)
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
