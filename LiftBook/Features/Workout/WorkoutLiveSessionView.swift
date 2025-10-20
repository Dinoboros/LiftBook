//
//  WorkoutLiveSessionView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 17/10/2025.
//

import SwiftUI
import SwiftData

struct WorkoutLiveSessionView: View {
    @Environment(\.modelContext) private var modelContext
    
    let workout: Workout?

    init(workout: Workout? = nil) {
        self.workout = workout
    }

    var body: some View {
        if let workout = workout {
            Text(workout.name)
        } else {
            Text("Session of " + Date().formatted(date: .abbreviated, time: .shortened))
                .font(.headline)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
        }
    }
}
