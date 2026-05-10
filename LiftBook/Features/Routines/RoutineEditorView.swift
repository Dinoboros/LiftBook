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
                    .padding(.horizontal, 14)
                    .frame(minHeight: 44)
                    .background {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(LBColor.surface.opacity(0.8))
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            Section("Exercises") {
                if routineDraft.exercises.isEmpty {
                    LBEmptyStateCard(
                        title: "No Exercises",
                        message: "Add exercises to build this routine.",
                        buttonTitle: "Add Exercise",
                        buttonVariant: .filled,
                        action: showExerciseSelection
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                    LBTipCard(text: "You can always adjust sets, reps and weight afterwards.")
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach($routineDraft.exercises) { exercise in
                        RoutineDraftExerciseCard(
                            exercise: exercise,
                            showsSubtitle: true,
                            onDelete: { deleteExercise(exercise.wrappedValue) }
                        )
                        .listRowInsets(
                            EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                        )
                        .listRowBackground(Color.clear)
                    }
                }
            }

            if !routineDraft.exercises.isEmpty {
                Section {
                    Button(action: showExerciseSelection) {
                        Label("Add Exercise", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(LBColor.background)
        .navigationTitle("Create Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: saveRoutine)
                    .disabled(!canSave)
            }
        }
        .lbKeyboardDismissToolbar()
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
        for: [Exercise.self, RoutineTemplate.self, RoutineTemplateExercise.self, RoutineTemplateSet.self],
        inMemory: true
    )
}
