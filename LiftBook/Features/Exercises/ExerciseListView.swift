//
//  ExerciseListView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftData
import SwiftUI

struct ExerciseListView: View {
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]

    @State private var searchText = ""

    private var filteredExercises: [Exercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return exercises
        }

        return exercises.filter { exercise in
            exercise.name.localizedStandardContains(query)
                || exercise.aliases.contains { $0.localizedStandardContains(query) }
        }
    }

    var body: some View {
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
                    ExerciseRowView(exercise: exercise)
                }
            }
        }
        .navigationTitle("Exercises")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}

private struct ExerciseRowView: View {
    let exercise: Exercise

    private var subtitle: String {
        if !exercise.primaryMuscles.isEmpty {
            return exercise.primaryMuscles.joined(separator: ", ")
        }

        return exercise.category
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(exercise.name)
                .font(.body)

            if !subtitle.isEmpty {
                Text(subtitle.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
    .modelContainer(for: [Exercise.self], inMemory: true)
}
