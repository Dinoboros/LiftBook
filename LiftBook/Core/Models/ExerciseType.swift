//
//  ExerciseType.swift
//  LiftBook
//
//  Created by Méryl VALIER on 19/10/2025.
//

import Foundation

enum ExerciseEquipment: String, CaseIterable {
    case bodyOnly = "body only"
    case machine = "machine"
    case dumbbell = "dumbbell"
    case barbell = "barbell"
    case cable = "cable"
    case kettlebells = "kettlebells"
    case bands = "bands"
    case medicineBall = "medicine ball"
    case exerciseBall = "exercise ball"
    case foamRoll = "foam roll"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .bodyOnly: return "Bodyweight"
        case .machine: return "Machine"
        case .dumbbell: return "Dumbbell"
        case .barbell: return "Barbell"
        case .cable: return "Cable"
        case .kettlebells: return "Kettlebells"
        case .bands: return "Bands"
        case .medicineBall: return "Medicine Ball"
        case .exerciseBall: return "Exercise Ball"
        case .foamRoll: return "Foam Roller"
        case .other: return "Other"
        }
    }
    
    static var commonEquipments: [ExerciseEquipment] {
        return [.bodyOnly, .dumbbell, .barbell, .machine, .cable]
    }
}

enum MuscleGroup: String, CaseIterable {
    case chest = "chest"
    case shoulders = "shoulders"
    case triceps = "triceps"
    case back = "lats"
    case biceps = "biceps"
    case abdominals = "abdominals"
    case obliques = "obliques"
    case quadriceps = "quadriceps"
    case hamstrings = "hamstrings"
    case glutes = "glutes"
    case calves = "calves"
    
    var displayName: String {
        switch self {
        case .chest: return "Pectoraux"
        case .shoulders: return "Épaules"
        case .triceps: return "Triceps"
        case .back: return "Dos"
        case .biceps: return "Biceps"
        case .abdominals: return "Abdos"
        case .obliques: return "Obliques"
        case .quadriceps: return "Quadriceps"
        case .hamstrings: return "Ischio-jambiers"
        case .glutes: return "Fessiers"
        case .calves: return "Mollets"
        }
    }
    
    var isPush: Bool {
        return [.chest, .shoulders, .triceps].contains(self)
    }
    
    var isPull: Bool {
        return [.back, .biceps].contains(self)
    }
    
    var isLegs: Bool {
        return [.quadriceps, .hamstrings, .glutes, .calves].contains(self)
    }
    
    static var mainMuscleGroups: [MuscleGroup] {
        return [.chest, .back, .shoulders, .abdominals, .quadriceps, .hamstrings, .glutes, .biceps, .triceps]
    }
}
