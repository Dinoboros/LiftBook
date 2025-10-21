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
    
    var title: LocalizedStringKey {
        switch self {
            case .home: return L10n.App.tabHomeTitle
            case .workout: return L10n.App.tabWorkoutTitle
            case .profile: return L10n.App.tabProfileTitle
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

