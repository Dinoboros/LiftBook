//
//  AppRouter.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI

@Observable
final class AppRouter {
    var selectedTab: MainTab = .home
    var homePath = NavigationPath()
    var sessionPath = NavigationPath()
    var profilePath = NavigationPath()

    func navigate(_ route: HomeRoute) { homePath.append(route) }
    func navigate(_ route: WorkoutSessionRoute) { sessionPath.append(route) }
    func navigate(_ route: ProfileRoute) { profilePath.append(route) }

    func popToRoot(of tab: MainTab) {
        switch tab {
        case .home: homePath = .init()
        case .session: sessionPath = .init()
        case .profile: profilePath = .init()
        }
    }

    func go(to tab: MainTab) { selectedTab = tab }
}
