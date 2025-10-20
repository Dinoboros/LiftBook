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
    @State private var selectedExercises: [ExerciseSet] = []
    @State private var showExercicesPicker: Bool = false

    var body: some View {
        Form {
            Section {
                TextField(L10n.Workout.WorkoutCreation.templateNamePlaceholder, text: $templateName)
            }
            Section(L10n.Workout.WorkoutCreation.exercisesSectionTitle) {
                Button(L10n.Workout.WorkoutCreation.addExerciseButtonTitle) { showExercicesPicker = true }
                if !selectedExercises.isEmpty {
                    ForEach(selectedExercises, id: \.id) { exercise in
                        HStack {
                            Text(exercise.exercise?.name ?? "Unknown")
                        }
                    }
                }
            }
        }
        .navigationTitle(L10n.Workout.WorkoutCreation.newWorkoutTitle)
        .sheet(isPresented: $showExercicesPicker) {
            ExercisePickerView(selectedExercises: $selectedExercises)
        }
    }
}

#Preview {
    WorkoutTemplateFormView()
}
