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

    @State private var templateName: String = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var showExercisePicker: Bool = false

    @State private var workoutExercises: [WorkoutExercise] = MockData.mockWorkoutExercises

    var body: some View {
        Form {
            Section {
                TextField(L10n.Workout.WorkoutCreation.templateNamePlaceholder, text: $templateName)
            }

            Section(L10n.Workout.WorkoutCreation.exercisesSectionTitle) {
                ForEach(workoutExercises, id: \.id) { workoutExercise in
                    ExerciseRowView(
                        workoutExercise: workoutExercise,
                        onDelete: {
                            removeExercise(workoutExercise)
                        }
                    )
                }

                Button {
                    showExercisePicker = true
                } label: {
                    Text("Add Exercise")
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle(L10n.Workout.WorkoutCreation.newWorkoutTitle)
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView(selectedExercises: $selectedExercises)
        }
        .onChange(of: selectedExercises) { oldValue, newValue in
            for exercise in newValue {
                if !workoutExercises.contains(where: { $0.exercise?.id == exercise.id }) {
                    addExercise(exercise)
                }
            }
            selectedExercises.removeAll()
        }
    }

    private func addExercise(_ exercise: Exercise) {
        let workoutExercise = WorkoutExercise(exercise: exercise, order: workoutExercises.count)
        workoutExercises.append(workoutExercise)
    }

    private func removeExercise(_ workoutExercise: WorkoutExercise) {
        workoutExercises.removeAll { $0.id == workoutExercise.id }
    }
}

#Preview {
    WorkoutTemplateFormView()
}
