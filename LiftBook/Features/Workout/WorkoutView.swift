//
//  WorkoutView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 07/09/2025.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(AppRouter.self) private var router
    
    @State private var workoutStore: WorkoutStore
    @State private var showWorkoutTemplateForm: Bool = false
    @State private var workouts: [Workout] = []
    
    init(workoutStore: WorkoutStore) {
        _workoutStore = State(initialValue: workoutStore)
    }
    
    private func loadWorkouts() {
        do {
            workouts = try workoutStore.getWorkouts()
        } catch {
            print("Failed to load workouts: \(error)")
        }
    }
    
    // Observe refreshTrigger from WorkoutStore (Option 2)
    private var refreshTrigger: Int {
        workoutStore.refreshTrigger
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                Button(L10n.Workout.startAnEmptyWorkoutButtonTitle) { router.navigate(.emptyWorkout) }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
                
                Button(L10n.Workout.createANewTemplateButtonTitle) { showWorkoutTemplateForm = true }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
            
            if workouts.isEmpty {
                ContentUnavailableView(
                    "No workouts",
                    systemImage: "dumbbell",
                    description: Text("You don't have any workout saved, create one to start!")
                )
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Workout.myWorkoutsTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.bottom)
                    
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(workouts) { workout in
                            VStack {
                                HStack(alignment: .top) {
                                    Text(workout.name)
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                    Menu {
                                        Button("Démarrer", systemImage: "play.fill") {
                                            router.navigate(.startWorkout(workout))
                                        }
                                        Divider()
                                        Button(role: .destructive) {
                                            do {
                                                try workoutStore.delete(workout)
                                                // Refresh is handled by refreshTrigger observation (Option 2)
                                            } catch {
                                                print("Failed to delete workout: \(error)")
                                            }
                                        } label: {
                                            Label("Supprimer", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.top, 4)
                                }
                                //TODO: remplacer par une sheet plutot
                                Button(L10n.Workout.startWorkoutButtonTitle) { router.navigate(.startWorkout(workout)) }
                                    .buttonStyle(PrimaryButtonStyle())
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
            Spacer()
        }
        .navigationDestination(for: WorkoutRoute.self) { route in
            switch route {
                case .emptyWorkout:
                    WorkoutLiveSessionView()
                case .newWorkoutTemplate:
                    WorkoutTemplateFormView()
                case .startWorkout(let workout):
                    Text(workout.name)
            }
        }
        .sheet(isPresented: $showWorkoutTemplateForm) {
            // Option 1: Pass callback to notify when workout is created
            WorkoutTemplateFormView(onWorkoutCreated: {
                loadWorkouts()
            })
        }
        // Option 2: Observe refreshTrigger from WorkoutStore
        .onChange(of: refreshTrigger) { _, _ in
            loadWorkouts()
        }
        .onAppear {
            loadWorkouts()
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Workout.self, Exercise.self, ExerciseSet.self, WorkoutExercise.self,
            configurations: config
        )
        let context = ModelContext(container)
        context.insert(Workout(name: "Mock Workout A"))
        context.insert(Workout(name: "Mock Workout B"))
        return WorkoutView(workoutStore: WorkoutStore(modelContext: context))
            .environment(AppRouter())
            .modelContainer(container)
    } catch {
        return Text("Preview failed: \(error.localizedDescription)")
    }
}

