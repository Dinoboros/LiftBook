//
//  ExerciseCreationFormView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 17/10/2025.
//

import SwiftUI
import SwiftData

struct ExerciseCreationFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var exerciseName: String = ""
    @State private var selectedEquipment: ExerciseEquipment? = nil
    @State private var selectedMuscles: [MuscleGroup] = []
    @State private var instructions: String = ""
    
    @State private var showMusclesSelection: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(L10n.ExercisePicker.ExerciseCreationForm.namePlaceholder, text: $exerciseName)
                }
                
                Section(L10n.ExercisePicker.ExerciseCreationForm.equipmentSectionTitle) {
                    Picker(selection: $selectedEquipment) {
                        ForEach(ExerciseEquipment.allCases, id: \.self) { equipment in
                            Text(equipment.displayName).tag(Optional(equipment))
                        }
                    } label: {
                        if selectedEquipment != nil {
                            Text(L10n.ExercisePicker.ExerciseCreationForm.equipmentSelectedPlaceholder)
                        } else {
                            Text(L10n.ExercisePicker.ExerciseCreationForm.noEquipmentSelectedPlaceholder)
                        }
                    }
                }
                
                Section(L10n.ExercisePicker.ExerciseCreationForm.musclesSectionTitle) {
                    Button {
                        showMusclesSelection = true
                    }
                    label: {
                        Text("Muscles: \(selectedMuscles.sorted(by: { $0.displayName < $1.displayName }).map { $0.displayName }.joined(separator: ", "))")
                    }
                }
                
                Section(L10n.ExercisePicker.ExerciseCreationForm.instructionsSectionTitle) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 140)
                        .overlay(alignment: .topLeading) {
                            if instructions.isEmpty {
                                Text(L10n.ExercisePicker.ExerciseCreationForm.instructionsPlaceholder)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                }
                
                Section {
                    Button(L10n.ExercisePicker.ExerciseCreationForm.createExerciseButtonTitle) {
                        
                    }
                }
            }
            .navigationTitle(L10n.ExercisePicker.ExerciseCreationForm.newExerciseTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showMusclesSelection) {
                NavigationStack {
                    MuscleSelectionView(selectedMuscles: $selectedMuscles)
                }
            }
        }
    }
}

#Preview {
    ExerciseCreationFormView()
}
