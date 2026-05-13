//
//  ExerciseLibrarySeeder.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import Foundation
import SwiftData

struct ExerciseLibrarySeeder {
    private let importer: any ExerciseSeedImporting

    init(importer: any ExerciseSeedImporting = ExerciseSeedImporter()) {
        self.importer = importer
    }

    @MainActor
    func prepareLibrary(
        into modelContext: ModelContext,
        existingExercises: [Exercise],
        progress: @MainActor (ExerciseSeedImporter.Progress) -> Void = { _ in }
    ) async throws -> ExerciseLibraryPreparationResult {
        guard needsSeedImport(existingExercises) else {
            return .alreadyPrepared(count: existingExercises.count)
        }

        let customExerciseCount = existingExercises.filter(\.isCustom).count
        let seedExercises = existingExercises.filter { !$0.isCustom }

        do {
            replaceSeedDataIfNeeded(seedExercises, in: modelContext)

            let result = try await importer.importExercises(
                into: modelContext,
                progress: progress
            )

            return .imported(count: customExerciseCount + result.importedCount)
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    private func needsSeedImport(_ exercises: [Exercise]) -> Bool {
        let seedExercises = exercises.filter { !$0.isCustom }

        return seedExercises.isEmpty || seedExercises.contains { exercise in
            exercise.category.isEmpty
                && exercise.primaryMuscles.isEmpty
                && exercise.equipment.isEmpty
        }
    }

    @MainActor
    private func replaceSeedDataIfNeeded(
        _ exercises: [Exercise],
        in modelContext: ModelContext
    ) {
        for exercise in exercises {
            modelContext.delete(exercise)
        }
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
