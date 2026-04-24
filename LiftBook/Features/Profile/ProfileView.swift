//
//  ProfileView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI

struct ProfileView: View {
    @State private var path: [ProfileRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Library") {
                    NavigationLink(value: ProfileRoute.exerciseList) {
                        Label("Exercise List", systemImage: "figure.strengthtraining.traditional")
                    }
                }
                Section {
                    NavigationLink(value: ProfileRoute.settings) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationDestination(for: ProfileRoute.self, destination: destination)
        }
    }

    @ViewBuilder
    private func destination(for route: ProfileRoute) -> some View {
        switch route {
        case .settings:
            SettingsView()
        case .exerciseList:
            ExerciseListView()
        }
    }
}

#Preview {
    ProfileView()
}
