//
//  Exercise.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: String
    var name: String
    var category: String = ""
    var exerciseDescription: String?
    var equipment: [String] = []
    var instructions: [String] = []
    var primaryMuscles: [String] = []
    var secondaryMuscles: [String] = []
    var aliases: [String] = []
    var variationsOn: [String] = []
    var videoURL: String?
    var isCustom: Bool = false

    init(
        id: String,
        name: String,
        category: String,
        exerciseDescription: String? = nil,
        equipment: [String] = [],
        instructions: [String] = [],
        primaryMuscles: [String] = [],
        secondaryMuscles: [String] = [],
        aliases: [String] = [],
        variationsOn: [String] = [],
        videoURL: String? = nil,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.exerciseDescription = exerciseDescription
        self.equipment = equipment
        self.instructions = instructions
        self.primaryMuscles = primaryMuscles
        self.secondaryMuscles = secondaryMuscles
        self.aliases = aliases
        self.variationsOn = variationsOn
        self.videoURL = videoURL
        self.isCustom = isCustom
    }
}
