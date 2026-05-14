import Foundation

struct ExerciseDraft: Equatable {
    var name = ""
    var category = ""
    var equipmentText = ""
    var primaryMusclesText = ""
    var secondaryMusclesText = ""
    var aliasesText = ""
    var descriptionText = ""
    var instructionsText = ""

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedName.isEmpty
    }

    var trimmedCategory: String {
        category.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var exerciseDescription: String? {
        optionalString(descriptionText)
    }

    var equipment: [String] {
        commaSeparatedValues(from: equipmentText)
    }

    var primaryMuscles: [String] {
        commaSeparatedValues(from: primaryMusclesText)
    }

    var secondaryMuscles: [String] {
        commaSeparatedValues(from: secondaryMusclesText)
    }

    var aliases: [String] {
        commaSeparatedValues(from: aliasesText)
    }

    var instructions: [String] {
        newlineSeparatedValues(from: instructionsText)
    }

    init() {}

    init(exercise: Exercise) {
        name = exercise.name
        category = exercise.category
        equipmentText = exercise.equipment.joined(separator: ", ")
        primaryMusclesText = exercise.primaryMuscles.joined(separator: ", ")
        secondaryMusclesText = exercise.secondaryMuscles.joined(separator: ", ")
        aliasesText = exercise.aliases.joined(separator: ", ")
        descriptionText = exercise.exerciseDescription ?? ""
        instructionsText = exercise.instructions.joined(separator: "\n")
    }

    private func optionalString(_ text: String) -> String? {
        let trimmedValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }

    private func commaSeparatedValues(from text: String) -> [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func newlineSeparatedValues(from text: String) -> [String] {
        text.split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}
