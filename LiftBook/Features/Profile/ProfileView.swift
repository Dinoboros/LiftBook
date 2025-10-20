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
            Button(L10n.Profile.settingsButtonTitle) {
                router.navigate(.settings)
            }
            Button(L10n.Profile.editProfileButtonTitle) {
                router.navigate(.editProfile)
            }
            Button(L10n.Profile.exerciseListButtonTitle) {
                router.navigate(.exerciseList)
            }
        }
        .navigationTitle(L10n.App.tabProfileTitle)
        .navigationDestination(for: ProfileRoute.self) { route in
            switch route {
                case .settings:
                    EmptyView()
                case .editProfile:
                    EmptyView()
                case .exerciseList:
                    ExerciceListView()
            }
        }
    }
}

#Preview {
    ProfileView()
}
