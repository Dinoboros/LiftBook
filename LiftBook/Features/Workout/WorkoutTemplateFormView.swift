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
            Section("Template Name") {
                TextField("Template Name", text: $templateName)
            }
            Section("Exercices") {
                Button("Add Exercices") { showExercicesPicker = true }
                if !selectedExercises.isEmpty {
                    ForEach(selectedExercises, id: \.id) { exercise in
                        HStack {
                            Text(exercise.exercise?.name ?? "Unknown")
                        }
                    }
                }
            }
        }
        .navigationTitle("New Workout")
        .sheet(isPresented: $showExercicesPicker) {
            ExercisePickerView(selectedExercises: $selectedExercises)
        }
    }
}

#Preview {
    WorkoutTemplateFormView()
}
