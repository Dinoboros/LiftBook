//
//  ExerciseLibrarySeeder.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import Foundation
import SwiftData

struct ExerciseLibrarySeeder {
    @MainActor
    func prepareLibrary(
        into modelContext: ModelContext,
        existingExercises: [Exercise],
        progress: @MainActor (ExerciseSeedImporter.Progress) -> Void = { _ in }
    ) async throws -> ExerciseLibraryPreparationResult {
        guard needsSeedImport(existingExercises) else {
            return .alreadyPrepared(count: existingExercises.count)
        }

        try replaceStaleSeedDataIfNeeded(existingExercises, in: modelContext)

        let result = try await ExerciseSeedImporter().importExercises(
            into: modelContext,
            progress: progress
        )

        return .imported(count: result.importedCount)
    }

    private func needsSeedImport(_ exercises: [Exercise]) -> Bool {
        exercises.isEmpty || exercises.contains { exercise in
            exercise.category.isEmpty
                && exercise.primaryMuscles.isEmpty
                && exercise.equipment.isEmpty
        }
    }

    @MainActor
    private func replaceStaleSeedDataIfNeeded(
        _ exercises: [Exercise],
        in modelContext: ModelContext
    ) throws {
        guard !exercises.isEmpty else {
            return
        }

        for exercise in exercises {
            modelContext.delete(exercise)
        }

        try modelContext.save()
    }
}

enum ExerciseLibraryPreparationResult: Equatable {
    case alreadyPrepared(count: Int)
    case imported(count: Int)

    var count: Int {
        switch self {
        case .alreadyPrepared(let count), .imported(let count):
            count
        }
    }
}
