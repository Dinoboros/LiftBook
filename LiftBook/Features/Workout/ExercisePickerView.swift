//
//  ExercisePickerView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 17/10/2025.
//

import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: [SortDescriptor(\Exercise.name, comparator: .localizedStandard)])
    private var exercises: [Exercise]
    
    @Binding var selectedExercises: [ExerciseSet]
    
    @State private var selectedEquipment: ExerciseEquipment? = nil
    
    init(selectedExercises: Binding<[ExerciseSet]>) {
        self._selectedExercises = selectedExercises
    }
    
    @State private var searchText: String = ""
    
    private var filteredExercises: [Exercise] {
        var result = exercises
        
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let eq = selectedEquipment {
            result = result.filter { $0.equipmentEnum == eq }
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Exercices")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Rechercher un exercice")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Create") {
                            ExerciseCreationFormView()
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
                .safeAreaInset(edge: .top) {
                    VStack(spacing: 8) {
                        // Équipement courant
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                Button(selectedEquipment == nil ? "Tous" : "Tous") {
                                    selectedEquipment = nil
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(selectedEquipment == nil ? .accentColor : .gray.opacity(0.5))
                                
                                ForEach(ExerciseEquipment.commonEquipments, id: \.self) { eq in
                                    Button(eq.displayName) {
                                        selectedEquipment = eq
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(selectedEquipment == eq ? .accentColor : .gray.opacity(0.3))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
        }
    }
    
    private var content: some View {
        Group {
            if exercises.isEmpty {
                emptyState
            } else {
                exercisesList
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No exercises",
            systemImage: "dumbbell",
            description: Text("You can create your custom exercises")
        )
    }
    
    private var exercisesList: some View {
        // TODO: ajouter des elements pour filtrer plus rapidement la liste
        List(filteredExercises, id: \.id) { exercise in
            row(for: exercise)
        }
        .listStyle(.insetGrouped)
    }
    
    private func row(for exercise: Exercise) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                if let equipment = exercise.equipment, !equipment.isEmpty {
                    Text(equipment)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if selectedExercises.contains(where: { $0.exercise?.id == exercise.id }) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let existingSet = selectedExercises.first(where: { $0.exercise?.id == exercise.id }) {
                selectedExercises.removeAll { $0.id == existingSet.id }
            } else {
                let newSet = ExerciseSet(exercise: exercise, reps: 10, weight: 20.0, rest: 90)
                selectedExercises.append(newSet)
            }
        }
    }
}

#Preview {
    ExercisePickerView(selectedExercises: Binding(get: { [] }, set: { _ in }))
        .modelContainer(for: ExerciseSet.self)
}
