//
//  MainTab.swift
//  LiftBook
//
//  Created by Méryl VALIER on 08/09/2025.
//

import SwiftUI

enum MainTab: String, CaseIterable, Identifiable {
    case home
    case session
    case profile
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
            case .home: return "Home"
            case .session: return "Workout"
            case .profile: return "Profile"
        }
    }
    
    var tabIcon: String {
        switch self {
            case .home: return "house"
            case .session: return "dumbbell.fill"
            case .profile: return "person"
        }
    }
}
