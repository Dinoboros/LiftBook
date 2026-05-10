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

private struct ExerciseSeedSummaryRow: View {
    let exerciseCount: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "list.bullet.rectangle")
                .foregroundStyle(LBColor.workoutStart)
                .imageScale(.large)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(exerciseCount) exercises")
                    .font(.headline)

                Text("Resources/Files/exercises.json")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ExerciseSeedDebugRow: View {
    let exercise: ExerciseSeedDebugExercise

    private var muscleText: String {
        exercise.primaryMuscles
            .map(\.capitalized)
            .joined(separator: ", ")
    }

    private var equipmentText: String {
        guard !exercise.equipment.isEmpty else {
            return "No equipment"
        }

        return exercise.equipment
            .map(\.capitalized)
            .joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
                .font(.headline)

            if !muscleText.isEmpty {
                Text(muscleText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 8) {
                Label(exercise.category.capitalized, systemImage: "tag")
                Label(equipmentText, systemImage: "dumbbell")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !exercise.aliases.isEmpty {
                Text("Aliases: \(exercise.aliases.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ExerciseSeedDebugSeedFile: Decodable {
    let exercises: [ExerciseSeedDebugExercise]
}

private struct ExerciseSeedDebugExercise: Decodable, Identifiable {
    var id: String { name }

    let name: String
    let category: String
    let equipment: [String]
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let aliases: [String]

    enum CodingKeys: String, CodingKey {
        case name
        case category
        case equipment
        case primaryMuscles = "primary_muscles"
        case secondaryMuscles = "secondary_muscles"
        case aliases
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        equipment = try container.decodeIfPresent([String].self, forKey: .equipment) ?? []
        primaryMuscles = try container.decodeIfPresent([String].self, forKey: .primaryMuscles) ?? []
        secondaryMuscles = try container.decodeIfPresent([String].self, forKey: .secondaryMuscles) ?? []
        aliases = try container.decodeIfPresent([String].self, forKey: .aliases) ?? []
    }
}

#Preview {
    NavigationStack {
        ExerciseSeedDebugView()
    }
}
