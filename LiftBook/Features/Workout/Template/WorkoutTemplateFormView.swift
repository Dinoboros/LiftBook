//
//  WorkoutTemplateFormView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 15/10/2025.
//

import SwiftUI
import SwiftData

struct WorkoutTemplateFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var onWorkoutCreated: (() -> Void)?
    
    @State private var templateName: String = ""
    @State private var showExercisePicker: Bool = false
    @State private var selectedExerciseIds: [String] = []

    @State private var workoutExercises: [WorkoutExercise] = []
    
    init(onWorkoutCreated: (() -> Void)? = nil) {
        self.onWorkoutCreated = onWorkoutCreated
    }

    private var currentSelectedIds: [String] {
        workoutExercises.sorted { $0.order < $1.order }.compactMap { $0.exercise?.id }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        TextField(L10n.Workout.WorkoutCreation.templateNamePlaceholder, text: $templateName)
                    }
                    
                    Section(header: Text(L10n.Workout.WorkoutCreation.exercisesSectionTitle)) {
                        ForEach(workoutExercises, id: \.id) { item in
                            ExerciseRowView(
                                workoutExercise: item,
                                onDelete: {
                                    removeExercise(item)
                                }
                            )
                        }
                    }
                }
                .navigationTitle(L10n.Workout.WorkoutCreation.newWorkoutTitle)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            createTemplate()
                        } label: {
                            Text("Create")
                                .padding()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .sheet(isPresented: $showExercisePicker) {
                    ExercisePickerView(selectedExerciseIds: $selectedExerciseIds)
                        .onDisappear {
                            updateWorkoutExercises()
                        }
                }
                .onAppear {
                    selectedExerciseIds = []
                }
                
                VStack {
                    Spacer()
                    Button(action: { showExercisePicker = true }) {
                        Text("Add Exercise")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 64)
                }
            }
        }
    }
    
    private func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(exercise: exercise, order: workoutExercises.count)
        workoutExercises.append(workoutExercise)
        modelContext.insert(workoutExercise)
    }
    
    private func removeExercise(_ workoutExercise: WorkoutExercise) {
        workoutExercises.removeAll { $0.id == workoutExercise.id }
    }

    private func updateWorkoutExercises() {
        let currentIds = currentSelectedIds
        let idsToAdd = selectedExerciseIds.filter { !currentIds.contains($0) }
        let idsToRemove = currentIds.filter { !selectedExerciseIds.contains($0) }

        workoutExercises.removeAll { workoutEx in
            if let exerciseId = workoutEx.exercise?.id {
                return idsToRemove.contains(exerciseId)
            }
            return false
        }

        for id in idsToAdd {
            if let exercise = getExerciseById(id) {
                addExercise(exercise)
            }
        }

        for (index, id) in selectedExerciseIds.enumerated() {
            if let idx = workoutExercises.firstIndex(where: { $0.exercise?.id == id }) {
                workoutExercises[idx].order = index
            }
        }

        workoutExercises.sort { $0.order < $1.order }
    }

    private func getExerciseById(_ id: String) -> Exercise? {
        let predicate = #Predicate<Exercise> { $0.id == id }
        let descriptor = FetchDescriptor<Exercise>(predicate: predicate)
        return try? modelContext.fetch(descriptor).first
    }

    private func createTemplate() {
        let workout = Workout(name: templateName)

        for exerciseId in selectedExerciseIds {
            if let exercise = getExerciseById(exerciseId) {
                let we = WorkoutExercise(exercise: exercise, order: workout.exercises.count)
                we.workout = workout
                workout.exercises.append(we)
            }
        }

        modelContext.insert(workout)
        try? modelContext.save()

        // Notify that a workout was created
        onWorkoutCreated?()
        
        dismiss()
    }
}

#Preview {
    WorkoutTemplateFormView()
        .modelContainer(for: [Exercise.self, ExerciseSet.self, Workout.self, WorkoutExercise.self])
}
