//
//  MainTab.swift
//  LiftBook
//
//  Created by Méryl VALIER on 08/09/2025.
//

import SwiftUI

enum MainTab: String, CaseIterable, Identifiable {
    case home, workout, profile
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
            case .home: return String(describing: L10n.App.tabHomeTitle)
            case .workout: return String(describing:    L10n.App.tabWorkoutTitle)
            case .profile: return String(describing: L10n.App.tabProfileTitle)
        }
    }
    
    var tabIcon: String {
        switch self {
            case .home: return "house"
            case .workout: return "dumbbell.fill"
            case .profile: return "person"
        }
    }
}
