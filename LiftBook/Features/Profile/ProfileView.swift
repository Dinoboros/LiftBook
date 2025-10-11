//
//  ProfileView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI

struct ProfileView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack {
            Button("Settings") {
                router.navigate(.settings)
            }
            Button("Edit Profile") {
                router.navigate(.editProfile)
            }
            Button("Exercise List") {
                router.navigate(.exerciseList)
            }
        }
        .navigationTitle("Profile")
        .navigationDestination(for: ProfileRoute.self) { route in
            switch route {
                case .settings:
                    Text("Settings")
                case .editProfile:
                    Text("Edit Profile")
                case .exerciseList:
                    ExerciceListView()
            }
        }
    }
}

#Preview {
    ProfileView()
}
