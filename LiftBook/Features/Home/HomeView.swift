//
//  HomeView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \RoutineTemplate.updatedAt, order: .reverse) private var routines: [RoutineTemplate]

    @State private var path: [HomeRoute] = []
    @State private var isShowingActiveWorkout = false

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    Button(action: startEmptyWorkout) {
                        Label("Start Empty Workout", systemImage: "plus.circle.fill")
                    }

                    Button(action: createRoutine) {
                        Label("Create Routine", systemImage: "doc.badge.plus")
                    }
                }

                Section("Routines") {
                    if routines.isEmpty {
                        ContentUnavailableView(
                            "No Routines",
                            systemImage: "list.bullet.rectangle",
                            description: Text("Saved routines will appear here.")
                        )
                    } else {
                        ForEach(routines) { routine in
                            HStack(spacing: 12) {
                                NavigationLink(value: HomeRoute.routineDetail(routine.id)) {
                                    RoutineRowView(routine: routine)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }

                                Button {
                                    startWorkout(from: routine)
                                } label: {
                                    Image(systemName: "play.fill")
                                        .font(.body.weight(.semibold))
                                        .frame(width: 38, height: 34)
                                }
                                .buttonStyle(.borderedProminent)
                                .accessibilityLabel("Start \(routine.name)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .navigationDestination(for: HomeRoute.self, destination: destination)
            .fullScreenCover(isPresented: $isShowingActiveWorkout) {
                NavigationStack {
                    ActiveWorkoutView()
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: HomeRoute) -> some View {
        switch route {
        case .routineEditor:
            RoutineEditorView()
        case .routineDetail(let routineID):
            RoutineDetailView(routineID: routineID)
        }
    }

    private func startEmptyWorkout() {
        isShowingActiveWorkout = true
    }

    private func startWorkout(from _: RoutineTemplate) {
        isShowingActiveWorkout = true
    }

    private func createRoutine() {
        path.append(.routineEditor)
    }
}

#Preview {
    HomeView()
        .modelContainer(
            for: [Exercise.self, RoutineTemplate.self, RoutineTemplateExercise.self],
            inMemory: true
        )
}

private struct RoutineRowView: View {
    let routine: RoutineTemplate

    private var exerciseCountText: String {
        let count = routine.exercises.count

        if count == 1 {
            return "1 exercise"
        }

        return "\(count) exercises"
    }

    private var exerciseSummary: String {
        let exerciseNames = routine.exercises
            .sorted { $0.sortOrder < $1.sortOrder }
            .prefix(3)
            .map(\.exerciseName)

        guard !exerciseNames.isEmpty else {
            return exerciseCountText
        }

        return exerciseNames.joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(routine.name)
                .font(.body)

            Text(exerciseSummary)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(exerciseCountText)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 2)
    }
}
