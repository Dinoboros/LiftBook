//
//  WorkoutSessionView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI

struct WorkoutSessionView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        VStack {
            Text("Workout Session")
        }
        .navigationDestination(for: WorkoutSessionRoute.self) { route in
            switch route {
                default:
                    Text("Workout Session")
            }
        }
    }
}

#Preview {
    WorkoutSessionView()
}
