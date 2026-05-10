import Foundation
import SwiftData

struct ExerciseService {
    @MainActor
    @discardableResult
    func createCustomExercise(
        from draft: ExerciseDraft,
        existingExercises: [Exercise],
        in modelContext: ModelContext
    ) throws -> Exercise {
        guard draft.canSave else {
            throw ExerciseServiceError.missingName
        }

        let exercise = Exercise(
            id: uniqueCustomIdentifier(
                for: draft.trimmedName,
                existingIDs: Set(existingExercises.map(\.id))
            ),
            name: draft.trimmedName,
            category: draft.trimmedCategory,
            exerciseDescription: draft.exerciseDescription,
            equipment: draft.equipment,
            instructions: draft.instructions,
            primaryMuscles: draft.primaryMuscles,
            secondaryMuscles: draft.secondaryMuscles,
            aliases: draft.aliases,
            videoURL: draft.videoURL,
            isCustom: true
        )

        modelContext.insert(exercise)
        try modelContext.save()
        return exercise
    }

    @MainActor
    func updateCustomExercise(
        _ exercise: Exercise,
        with draft: ExerciseDraft,
        in modelContext: ModelContext
    ) throws {
        guard exercise.isCustom else {
            throw ExerciseServiceError.seededExerciseIsReadOnly
        }

        guard draft.canSave else {
            throw ExerciseServiceError.missingName
        }

        exercise.name = draft.trimmedName
        exercise.category = draft.trimmedCategory
        exercise.exerciseDescription = draft.exerciseDescription
        exercise.equipment = draft.equipment
        exercise.instructions = draft.instructions
        exercise.primaryMuscles = draft.primaryMuscles
        exercise.secondaryMuscles = draft.secondaryMuscles
        exercise.aliases = draft.aliases
        exercise.videoURL = draft.videoURL

        try modelContext.save()
    }

    @MainActor
    func deleteCustomExercise(
        _ exercise: Exercise,
        in modelContext: ModelContext
    ) throws {
        guard exercise.isCustom else {
            throw ExerciseServiceError.seededExerciseIsReadOnly
        }

        modelContext.delete(exercise)
        try modelContext.save()
    }

    private func uniqueCustomIdentifier(
        for name: String,
        existingIDs: Set<String>
    ) -> String {
        let baseIdentifier = "custom-\(identifierBase(for: name))"
        var candidate = baseIdentifier
        var suffix = 2

        while existingIDs.contains(candidate) {
            candidate = "\(baseIdentifier)-\(suffix)"
            suffix += 1
        }

        return candidate
    }

    private func identifierBase(for name: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics
        let scalars = name.lowercased().unicodeScalars.map { scalar -> Character in
            allowedCharacters.contains(scalar) ? Character(scalar) : "-"
        }

        let collapsed = String(scalars)
            .split(separator: "-", omittingEmptySubsequences: true)
            .joined(separator: "-")

        return collapsed.isEmpty ? UUID().uuidString.lowercased() : collapsed
    }
}

enum ExerciseServiceError: LocalizedError, Equatable {
    case missingName
    case seededExerciseIsReadOnly

    var errorDescription: String? {
        switch self {
        case .missingName:
            "Enter an exercise name."
        case .seededExerciseIsReadOnly:
            "Bundled exercises cannot be edited or deleted."
        }
    }
}
