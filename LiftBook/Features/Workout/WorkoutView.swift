//
//  WorkoutView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI

struct WorkoutView: View {
    @Environment(AppRouter.self) private var router
    
    private let savedRoutineWorkouts = MockData.savedRoutineWorkouts

    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Button("Start an empty workout") { router.navigate(.emptyWorkout) }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                
                Button("Create a new template") { router.navigate(.newTemplate) }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text("My Workouts")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(savedRoutineWorkouts) { workout in
                        VStack {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.headline)
                            }
                            Button("Start workout") { router.navigate(.newLiveWorkout) }
                                .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
            
            Spacer()
        }
        .navigationDestination(for: WorkoutRoute.self) { route in
            switch route {
                case .emptyWorkout:
                    WorkoutLiveSessionView()
                case .newTemplate:
                    WorkoutTemplateFormView()
                default:
                    Text("Workout Session")
            }
        }
    }
}

#Preview {
    WorkoutView()
        .environment(AppRouter())
}
