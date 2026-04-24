//
//  ExerciseListView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftData
import SwiftUI

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]

    @State private var importState: ExerciseImportState = .idle
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

    private var needsSeedImport: Bool {
        exercises.isEmpty || exercises.contains { exercise in
            exercise.category.isEmpty
                && exercise.primaryMuscles.isEmpty
                && exercise.equipment.isEmpty
        }
    }

    var body: some View {
        Group {
            if importState.shouldShowStatus || exercises.isEmpty {
                importStatusView
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
        .task {
            await importExercisesIfNeeded()
        }
    }

    @ViewBuilder
    private var importStatusView: some View {
        switch importState {
        case .idle, .finished:
            ProgressView("Preparing exercise library")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .importing(let imported, let total):
            VStack(spacing: 12) {
                ProgressView(value: Double(imported), total: Double(max(total, 1)))
                    .frame(width: 220)
                Text("Importing \(imported) / \(total)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message):
            ContentUnavailableView {
                Label("Import Failed", systemImage: "exclamationmark.triangle")
            } description: {
                Text(message)
            } actions: {
                Button("Retry", action: retryImport)
            }
        }
    }

    @MainActor
    private func importExercisesIfNeeded() async {
        guard needsSeedImport else {
            importState = .finished
            return
        }

        guard !importState.isImporting else {
            return
        }

        importState = .importing(imported: 0, total: 0)

        do {
            try replaceStaleSeedDataIfNeeded()

            let importer = ExerciseSeedImporter()
            _ = try await importer.importExercises(into: modelContext) { progress in
                importState = .importing(imported: progress.imported, total: progress.total)
            }
            importState = .finished
        } catch {
            importState = .failed(error.localizedDescription)
        }
    }

    private func replaceStaleSeedDataIfNeeded() throws {
        guard !exercises.isEmpty else {
            return
        }

        for exercise in exercises {
            modelContext.delete(exercise)
        }

        try modelContext.save()
    }

    private func retryImport() {
        importState = .idle

        Task {
            await importExercisesIfNeeded()
        }
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

private enum ExerciseImportState: Equatable {
    case idle
    case importing(imported: Int, total: Int)
    case finished
    case failed(String)

    var isImporting: Bool {
        if case .importing = self {
            return true
        }
        return false
    }

    var shouldShowStatus: Bool {
        switch self {
        case .importing, .failed:
            return true
        case .idle, .finished:
            return false
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseListView()
    }
    .modelContainer(for: [Exercise.self], inMemory: true)
}
