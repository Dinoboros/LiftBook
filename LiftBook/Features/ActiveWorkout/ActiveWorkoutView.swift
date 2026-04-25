//
//  ActiveWorkoutView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss

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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Dismiss") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ActiveWorkoutView()
    }
}
