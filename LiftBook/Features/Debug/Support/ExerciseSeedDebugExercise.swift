//
//  ExerciseSeedDebugExercise.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

struct ExerciseSeedDebugExercise: Decodable, Identifiable {
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
