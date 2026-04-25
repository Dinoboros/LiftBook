//
//  ActiveWorkoutView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI

struct ActiveWorkoutView: View {
    var body: some View {
        List {
            Section {
                ContentUnavailableView(
                    "Empty Workout",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text("Workout logging will be wired here.")
                )
            }
        }
        .navigationTitle("Workout")
    }
}

#Preview {
    NavigationStack {
        ActiveWorkoutView()
    }
}
