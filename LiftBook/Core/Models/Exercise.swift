//
//  Exercise.swift
//  LiftBook
//
//  Created by Méryl VALIER on 01/10/2025.
//

import Foundation
import SwiftData

@Model
final class Exercise: Decodable {
    @Attribute(.unique) var id: String
    var name: String
    var equipment: String?
    var primaryMuscles: [String]
    var secondaryMuscles: [String]?
    var instructions: [String]
    var category: String
    var isCustom: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case equipment
        case primaryMuscles
        case secondaryMuscles
        case instructions
        case category
    }
    
    @Relationship(deleteRule: .nullify, inverse: \ExerciseSet.exercise)
    var sets: [ExerciseSet]?

    init(
        id: String,
        name: String,
        equipment: String?,
        primaryMuscles: [String],
        secondaryMuscles: [String]?,
        instructions: [String],
        category: String
    ) {
        self.id = id
        self.name = name
        self.equipment = equipment
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.instructions = instructions
        self.category = category
        self.isCustom = true
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .id),
            name: try container.decode(String.self, forKey: .name),
            equipment: try container.decodeIfPresent(String.self, forKey: .equipment),
            primaryMuscles: try container.decode([String].self, forKey: .primaryMuscles),
            secondaryMuscles: try container.decodeIfPresent([String].self, forKey: .secondaryMuscles),
            instructions: try container.decode([String].self, forKey: .instructions),
            category: try container.decode(String.self, forKey: .category)
        )
        self.isCustom = false
    }
}

extension Exercise {
    var equipmentEnum: ExerciseEquipment? {
        guard let value = equipment?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !value.isEmpty else {
            return nil
        }
        return ExerciseEquipment(rawValue: value)
    }
}
