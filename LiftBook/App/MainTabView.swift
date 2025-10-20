//
//  MainTabView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI

struct MainTabView: View {
    @Environment(AppRouter.self) private var router

    @State private var selectedTab: MainTab = .home

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            ForEach(MainTab.allCases, id: \.id) { tab in
                NavigationStack(path: pathBinding(for: tab)) {
                    content(for: tab)
                        .navigationTitle(tab.title)
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.tabIcon)
                }
                .tag(tab)
            }
        }
    }
    
    @ViewBuilder
    private func content(for tab: MainTab) -> some View {
        switch tab {
            case .home:
                HomeView()
            case .workout:
                WorkoutView()
            case .profile:
                ProfileView()
        }
    }
    
    private func pathBinding(for tab: MainTab) -> Binding<NavigationPath> {
        switch tab {
            case .home: 
                return Binding(get: { router.homePath }, set: { router.homePath = $0 })
            case .workout: 
                return Binding(get: { router.workoutPath }, set: { router.workoutPath = $0 })
            case .profile:
                return Binding(get: { router.profilePath }, set: { router.profilePath = $0 })
        }
    }

}

#Preview {
    MainTabView()
}
