//
//  ExerciseSeedDebugView.swift
//  LiftBook
//
//  Created by Codex on 10/05/2026.
//

import Foundation
import SwiftUI

struct ExerciseSeedDebugView: View {
    @State private var exercises: [ExerciseSeedDebugExercise] = []
    @State private var errorMessage: String?
    @State private var searchText = ""

    private var filteredExercises: [ExerciseSeedDebugExercise] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return exercises
        }

        return exercises.filter { exercise in
            exercise.name.localizedStandardContains(query)
                || exercise.category.localizedStandardContains(query)
                || exercise.equipment.contains { $0.localizedStandardContains(query) }
                || exercise.primaryMuscles.contains { $0.localizedStandardContains(query) }
                || exercise.secondaryMuscles.contains { $0.localizedStandardContains(query) }
                || exercise.aliases.contains { $0.localizedStandardContains(query) }
        }
    }

    var body: some View {
        Group {
            if let errorMessage {
                ContentUnavailableView(
                    "Exercise Seed Unavailable",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else if filteredExercises.isEmpty, !searchText.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List {
                    Section {
                        ExerciseSeedSummaryRow(exerciseCount: exercises.count)
                    }

                    Section("Exercises") {
                        ForEach(filteredExercises) { exercise in
                            ExerciseSeedDebugRow(exercise: exercise)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(LBColor.background)
            }
        }
        .navigationTitle("Default Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .task {
            loadExercisesIfNeeded()
        }
    }

    private func loadExercisesIfNeeded() {
        guard exercises.isEmpty, errorMessage == nil else {
            return
        }

        do {
            guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
                errorMessage = "The default exercise file could not be found in the app bundle."
                return
            }

            let data = try Data(contentsOf: url)
            let seedFile = try JSONDecoder().decode(ExerciseSeedDebugSeedFile.self, from: data)
            exercises = seedFile.exercises
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseSeedDebugView()
    }
}
