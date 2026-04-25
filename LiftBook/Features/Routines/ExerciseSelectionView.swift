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
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]

    let existingExerciseIDs: Set<String>
    let onAdd: ([Exercise]) -> Void

    @State private var searchText = ""
    @State private var selectedExerciseIDs: [String] = []

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
                    Button(addButtonTitle, action: addSelectedExercises)
                        .disabled(selectedExerciseIDs.isEmpty)
                }
            }
        }
    }

    private var addButtonTitle: String {
        if selectedExerciseIDs.isEmpty {
            return "Add"
        }

        return "Add \(selectedExerciseIDs.count)"
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

#Preview {
    ExerciseSelectionView(existingExerciseIDs: []) { _ in }
        .modelContainer(for: [Exercise.self], inMemory: true)
}
