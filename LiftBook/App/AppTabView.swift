//
//  AppTabView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI

struct AppTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.title, systemImage: AppTab.home.systemImage)
                }
                .tag(AppTab.home)

            ProfileView()
                .tabItem {
                    Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
                }
                .tag(AppTab.profile)
        }
    }
}

private enum AppTab: Hashable {
    case home
    case profile

    var title: String {
        switch self {
        case .home:
            "Home"
        case .profile:
            "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            "house"
        case .profile:
            "person"
        }
    }
}

#Preview {
    AppTabView()
}
