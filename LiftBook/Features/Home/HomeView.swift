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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
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
    }
}

#Preview {
    HomeView()
        .environment(AppRouter())
}
