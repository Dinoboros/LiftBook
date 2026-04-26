//
//  AppLaunchView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import SwiftData
import SwiftUI

struct AppLaunchView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            HomeView()
        } else {
            OnboardingView {
                hasCompletedOnboarding = true
            }
        }
    }
}

#Preview {
    AppLaunchView()
        .modelContainer(
            for: [
                Exercise.self,
                RoutineTemplate.self,
                RoutineTemplateExercise.self,
                WorkoutSession.self,
                WorkoutSessionExercise.self,
                WorkoutSet.self,
            ],
            inMemory: true
        )
}
