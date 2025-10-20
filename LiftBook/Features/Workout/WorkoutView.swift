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
                Button(L10n.Workout.startAnEmptyWorkoutButtonTitle) { router.navigate(.emptyWorkout) }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                
                Button(L10n.Workout.createANewTemplateButtonTitle) { router.navigate(.newWorkoutTemplate) }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
            
            
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Workout.myWorkoutsTitle)
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
                            Button(L10n.Workout.startWorkoutButtonTitle) { router.navigate(.newLiveWorkout) }
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
                case .newWorkoutTemplate:
                    WorkoutTemplateFormView()
            }
        }
    }
}

#Preview {
    WorkoutView()
        .environment(AppRouter())
}
