//
//  HomeView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    
    private let workouts = MockData.mockWorkouts
    private let savedRoutineWorkouts = MockData.savedRoutineWorkouts
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack {
                    Button("Start an empty workout") { router.navigate(.newLiveWorkout) }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 20)
                    
                    Button("Create a new template") { router.navigate(.newTemplateWorkout) }
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
                    
                    ForEach(savedRoutineWorkouts) { workout in
                        VStack {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.headline)
                            }
                            Spacer()
                            Button("Start workout") { router.navigate(.newLiveWorkout) }
                                .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
                
                VStack(alignment: .leading) {
                    Text("Recent Workouts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    ForEach(workouts) { workout in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(workout.name)
                                    .font(.headline)
                                Text("\(workout.completedSets)/\(workout.totalSets) sets completed")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                if let duration = workout.duration {
                                    Text("Duration: \(MockData.formatDuration(duration))")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(MockData.formatDate(workout.startedAt))
                                    .font(.subheadline)
                                if workout.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.headline)
                                }
                            }
                        }
                        .padding()
                        .background(workout.isCompleted ? Color.green.opacity(0.1) : Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                    }
                }
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
        .environment(AppRouter())
}
