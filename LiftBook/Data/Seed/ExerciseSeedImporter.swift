//
//  ExerciseSeedImporter.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftData

struct ExerciseSeedImporter {
    struct Progress {
        let imported: Int
        let total: Int
    }

    struct Result {
        let importedCount: Int
    }

    private struct SeedFile: Decodable {
        let categories: [String]
        let equipment: [String]
        let exercises: [SeedExercise]
        let muscleGroups: [String: [String]]
        let muscles: [String]

        enum CodingKeys: String, CodingKey {
            case categories
            case equipment
            case exercises
            case muscleGroups = "muscle_groups"
            case muscles
        }
    }

    private struct SeedExercise: Decodable {
        let aliases: [String]
        let category: String
        let description: String?
        let equipment: [String]
        let instructions: [String]
        let license: SeedLicense?
        let licenseAuthor: String?
        let name: String
        let primaryMuscles: [String]
        let secondaryMuscles: [String]
        let tempo: String?
        let tips: [String]
        let variationsOn: [String]

        enum CodingKeys: String, CodingKey {
            case aliases
            case category
            case description
            case equipment
            case instructions
            case license
            case licenseAuthor = "license_author"
            case name
            case primaryMuscles = "primary_muscles"
            case secondaryMuscles = "secondary_muscles"
            case tempo
            case tips
            case variationOn = "variation_on"
            case variationsOn = "variations_on"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            aliases = try container.decodeIfPresent([String].self, forKey: .aliases) ?? []
            category = try container.decode(String.self, forKey: .category)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            equipment = try container.decodeIfPresent([String].self, forKey: .equipment) ?? []
            instructions = try container.decodeIfPresent([String].self, forKey: .instructions) ?? []
            license = try container.decodeIfPresent(SeedLicense.self, forKey: .license)
            licenseAuthor = try container.decodeIfPresent(String.self, forKey: .licenseAuthor)
            name = try container.decode(String.self, forKey: .name)
            primaryMuscles = try container.decodeIfPresent([String].self, forKey: .primaryMuscles) ?? []
            secondaryMuscles = try container.decodeIfPresent([String].self, forKey: .secondaryMuscles) ?? []
            tempo = try container.decodeIfPresent(String.self, forKey: .tempo)
            tips = try container.decodeIfPresent([String].self, forKey: .tips) ?? []

            let variationOn = try container.decodeIfPresent([String].self, forKey: .variationOn) ?? []
            let variationsOn = try container.decodeIfPresent([String].self, forKey: .variationsOn) ?? []
            self.variationsOn = variationOn + variationsOn
        }
    }

    private struct SeedLicense: Decodable {
        let fullName: String
        let shortName: String
        let url: String

        enum CodingKeys: String, CodingKey {
            case fullName = "full_name"
            case shortName = "short_name"
            case url
        }
    }

    @MainActor
    func importExercises(
        into modelContext: ModelContext,
        progress: @MainActor (Progress) -> Void = { _ in }
    ) async throws -> Result {
        let seedFile = try loadSeedFile()
        let total = seedFile.exercises.count
        var usedIdentifiers = Set<String>()

        progress(Progress(imported: 0, total: total))

        for (index, seedExercise) in seedFile.exercises.enumerated() {
            let exercise = Exercise(
                id: uniqueIdentifier(for: seedExercise.name, index: index, usedIdentifiers: &usedIdentifiers),
                name: seedExercise.name,
                category: seedExercise.category,
                exerciseDescription: seedExercise.description,
                equipment: seedExercise.equipment,
                instructions: seedExercise.instructions,
                primaryMuscles: seedExercise.primaryMuscles,
                secondaryMuscles: seedExercise.secondaryMuscles,
                aliases: seedExercise.aliases,
                variationsOn: seedExercise.variationsOn
            )
            modelContext.insert(exercise)

            if (index + 1).isMultiple(of: 100) || index == total - 1 {
                progress(Progress(imported: index + 1, total: total))
                await Task.yield()
            }
        }

        try modelContext.save()
        return Result(importedCount: total)
    }

    private func loadSeedFile() throws -> SeedFile {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            throw ImportError.missingSeedFile
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(SeedFile.self, from: data)
    }

    private func uniqueIdentifier(for name: String, index: Int, usedIdentifiers: inout Set<String>) -> String {
        let baseIdentifier = identifierBase(for: name, fallbackIndex: index)
        var candidate = baseIdentifier
        var suffix = 2

        while usedIdentifiers.contains(candidate) {
            candidate = "\(baseIdentifier)-\(suffix)"
            suffix += 1
        }

        usedIdentifiers.insert(candidate)
        return candidate
    }

    private func identifierBase(for name: String, fallbackIndex: Int) -> String {
        let allowedCharacters = CharacterSet.alphanumerics
        let scalars = name.lowercased().unicodeScalars.map { scalar -> Character in
            allowedCharacters.contains(scalar) ? Character(scalar) : "-"
        }

        let collapsed = String(scalars)
            .split(separator: "-", omittingEmptySubsequences: true)
            .joined(separator: "-")

        return collapsed.isEmpty ? "exercise-\(fallbackIndex + 1)" : collapsed
    }
}

protocol ExerciseSeedImporting {
    @MainActor
    func importExercises(
        into modelContext: ModelContext,
        progress: @MainActor (ExerciseSeedImporter.Progress) -> Void
    ) async throws -> ExerciseSeedImporter.Result
}

extension ExerciseSeedImporter: ExerciseSeedImporting {}

enum ImportError: LocalizedError {
    case missingSeedFile

    var errorDescription: String? {
        switch self {
        case .missingSeedFile:
            "The bundled exercise library could not be found."
        }
    }
}
