//
//  WeightUnit.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

enum WeightUnit: String, CaseIterable, Identifiable {
    case kilograms = "kg"
    case pounds = "lb"

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .kilograms:
            return "Kilograms"
        case .pounds:
            return "Pounds"
        }
    }
}
