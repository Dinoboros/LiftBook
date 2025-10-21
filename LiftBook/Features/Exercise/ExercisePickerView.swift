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
    
    @Binding var selectedExercises: [Exercise]
    
    @State private var selectedEquipment: ExerciseEquipment? = nil
    @State private var showExerciseCreationForm: Bool = false

    init(selectedExercises: Binding<[Exercise]>) {
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
                .navigationTitle(L10n.ExercisePicker.exercisesListTitle)
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic), prompt: L10n.ExercisePicker.searchExercisesPlaceholder)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(L10n.ExercisePicker.createExerciseButtonTitle) {
                           showExerciseCreationForm = true
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .safeAreaInset(edge: .top) {
                    VStack(spacing: 8) {
                        equipmentButtonsList
                    }
                }
                .sheet(isPresented: $showExerciseCreationForm) {
                    ExerciseCreationFormView()
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
            L10n.ExercisePicker.noExercisesTitle,
            systemImage: "dumbbell",
            description: Text(L10n.ExercisePicker.noExercisesDescription)
        )
    }

    private var equipmentButtonsList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(L10n.ExercisePicker.allEquipmentButtonTitle) {
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
    
    private var exercisesList: some View {
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
            if selectedExercises.contains(where: { $0.id == exercise.id }) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if selectedExercises.contains(where: { $0.id == exercise.id }) {
                selectedExercises.removeAll { $0.id == exercise.id }
            } else {
                selectedExercises.append(exercise)
            }
        }
    }
}

#Preview {
    ExercisePickerView(selectedExercises: Binding(get: { [] }, set: { _ in }))
        .modelContainer(for: [Exercise.self, ExerciseSet.self])
}
