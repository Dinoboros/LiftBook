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
    var tips: [String] = []
    var tempo: String?
    var variationsOn: [String] = []
    var videoURL: String?
    var licenseFullName: String?
    var licenseShortName: String?
    var licenseURL: String?
    var licenseAuthor: String?

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
        tips: [String] = [],
        tempo: String? = nil,
        variationsOn: [String] = [],
        videoURL: String? = nil,
        licenseFullName: String? = nil,
        licenseShortName: String? = nil,
        licenseURL: String? = nil,
        licenseAuthor: String? = nil
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
        self.tips = tips
        self.tempo = tempo
        self.variationsOn = variationsOn
        self.videoURL = videoURL
        self.licenseFullName = licenseFullName
        self.licenseShortName = licenseShortName
        self.licenseURL = licenseURL
        self.licenseAuthor = licenseAuthor
    }
}
