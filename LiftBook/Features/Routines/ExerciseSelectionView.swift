//
//  ExerciseSelectionView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import SwiftData
import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.exerciseService) private var exerciseService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]

    let existingExerciseIDs: Set<String>
    let onAdd: ([Exercise]) -> Void

    @State private var searchText = ""
    @State private var selectedExerciseIDs: [String] = []
    @State private var exerciseEditorMode: CustomExerciseEditorMode?
    @State private var exerciseDeletionRequest: CustomExerciseDeletionRequest?
    @State private var exerciseError: ExerciseSelectionError?

    private var filteredExercises: [Exercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return exercises
        }

        return exercises.filter { exercise in
            exercise.name.localizedStandardContains(query)
                || exercise.aliases.contains { $0.localizedStandardContains(query) }
                || exercise.primaryMuscles.contains { $0.localizedStandardContains(query) }
        }
    }

    private var selectedExercises: [Exercise] {
        let exercisesByID = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })

        return selectedExerciseIDs.compactMap { exercisesByID[$0] }
    }

    private var selectedExerciseIDSet: Set<String> {
        Set(selectedExerciseIDs)
    }

    var body: some View {
        NavigationStack {
            Group {
                if exercises.isEmpty {
                    ContentUnavailableView(
                        "No Exercises",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("The exercise library is not available.")
                    )
                } else if filteredExercises.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    List(filteredExercises) { exercise in
                        ExerciseSelectionRow(
                            exercise: exercise,
                            isSelected: selectedExerciseIDSet.contains(exercise.id),
                            isAlreadyAdded: existingExerciseIDs.contains(exercise.id),
                            onToggle: { toggleExercise(exercise) }
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if exercise.isCustom {
                                Button {
                                    editCustomExercise(exercise)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)

                                Button(role: .destructive) {
                                    requestDeleteCustomExercise(exercise)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create", action: createCustomExercise)
                        .accessibilityLabel("Create custom exercise")
                }
            }
            .safeAreaInset(edge: .bottom) {
                addSelectedExercisesButton
            }
            .lbKeyboardDismissToolbar()
            .animation(.snappy(duration: 0.22), value: selectedExerciseIDs.isEmpty)
            .sheet(item: $exerciseEditorMode) { mode in
                CustomExerciseEditorView(mode: mode)
            }
            .confirmationDialog(
                "Delete Custom Exercise?",
                isPresented: isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Exercise", role: .destructive, action: deleteRequestedCustomExercise)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(deleteConfirmationMessage)
            }
            .alert(item: $exerciseError) { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var isShowingDeleteConfirmation: Binding<Bool> {
        Binding {
            exerciseDeletionRequest != nil
        } set: { isPresented in
            if !isPresented {
                exerciseDeletionRequest = nil
            }
        }
    }

    private var deleteConfirmationMessage: String {
        guard let exerciseDeletionRequest else {
            return "This custom exercise will be removed from the library."
        }

        return "This will remove \"\(exerciseDeletionRequest.exerciseName)\" from the exercise library."
    }

    @ViewBuilder
    private var addSelectedExercisesButton: some View {
        if !selectedExerciseIDs.isEmpty {
            Button(action: addSelectedExercises) {
                Label(addButtonTitle, systemImage: "plus.circle.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 54)
                    .background {
                        Capsule()
                            .fill(LBColor.workoutStart)
                    }
                    .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private var addButtonTitle: String {
        if selectedExerciseIDs.count == 1 {
            return "Add 1 Exercise"
        }

        return "Add \(selectedExerciseIDs.count) Exercises"
    }

    private func toggleExercise(_ exercise: Exercise) {
        guard !existingExerciseIDs.contains(exercise.id) else {
            return
        }

        if selectedExerciseIDSet.contains(exercise.id) {
            selectedExerciseIDs.removeAll { $0 == exercise.id }
        } else {
            selectedExerciseIDs.append(exercise.id)
        }
    }

    private func addSelectedExercises() {
        onAdd(selectedExercises)
        dismiss()
    }

    private func createCustomExercise() {
        exerciseEditorMode = .create()
    }

    private func editCustomExercise(_ exercise: Exercise) {
        guard exercise.isCustom else {
            return
        }

        exerciseEditorMode = .edit(exercise)
    }

    private func requestDeleteCustomExercise(_ exercise: Exercise) {
        guard exercise.isCustom else {
            return
        }

        exerciseDeletionRequest = CustomExerciseDeletionRequest(
            exerciseID: exercise.id,
            exerciseName: exercise.name
        )
    }

    private func deleteRequestedCustomExercise() {
        guard let exerciseDeletionRequest else {
            return
        }

        defer {
            self.exerciseDeletionRequest = nil
        }

        guard let exercise = exercises.first(where: { $0.id == exerciseDeletionRequest.exerciseID }) else {
            return
        }

        do {
            selectedExerciseIDs.removeAll { $0 == exercise.id }
            try exerciseService.deleteCustomExercise(exercise, in: modelContext)
        } catch {
            exerciseError = ExerciseSelectionError(
                title: "Could Not Delete Exercise",
                message: error.localizedDescription
            )
        }
    }
}

private struct ExerciseSelectionRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let isAlreadyAdded: Bool
    let onToggle: () -> Void

    private var subtitle: String {
        if !exercise.primaryMuscles.isEmpty {
            return exercise.primaryMuscles.joined(separator: ", ").capitalized
        }

        return exercise.category.capitalized
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.body)
                        .foregroundStyle(.primary)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if exercise.isCustom {
                    Text("Custom")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            Capsule()
                                .fill(Color.secondary.opacity(0.12))
                        }
                }

                if isAlreadyAdded {
                    Text("Added")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: checkmarkSystemImage)
                    .font(.title3)
                    .foregroundStyle(checkmarkColor)
                    .frame(width: 28, height: 28)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isAlreadyAdded)
    }

    private var checkmarkSystemImage: String {
        if isSelected || isAlreadyAdded {
            return "checkmark.circle.fill"
        }

        return "circle"
    }

    private var checkmarkColor: Color {
        if isSelected {
            return .accentColor
        }

        return .secondary
    }
}

private struct CustomExerciseDeletionRequest {
    let exerciseID: String
    let exerciseName: String
}

private struct ExerciseSelectionError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

#Preview {
    ExerciseSelectionView(existingExerciseIDs: []) { _ in }
        .modelContainer(for: [Exercise.self], inMemory: true)
}
