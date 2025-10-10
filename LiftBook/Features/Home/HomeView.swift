//
//  HomeView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        VStack {
            Button("New Live Workout") {
                router.navigate(.newLiveWorkout)
            }
            Button("New Template Workout") {
                router.navigate(.newTemplateWorkout)
            }
        }
        .navigationDestination(for: HomeRoute.self) { route in
            switch route {
                case .newLiveWorkout:
                    Text("New Live Workout")
                case .newTemplateWorkout:
                    Text("New Template Workout")
            }
        }
    }
}

#Preview {
    HomeView()
}
