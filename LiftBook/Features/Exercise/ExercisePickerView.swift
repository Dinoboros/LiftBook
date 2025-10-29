//
//  ExercisePickerView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 17/10/2025.
//

import SwiftUI
import SwiftData

struct ExercisePickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: [SortDescriptor(\Exercise.name, comparator: .localizedStandard)])
    private var exercises: [Exercise]

    @Binding var selectedExerciseIds: [String]
    
    @State private var selectedEquipment: ExerciseEquipment? = nil
    @State private var showExerciseCreationForm: Bool = false

    init(selectedExerciseIds: Binding<[String]>) {
        self._selectedExerciseIds = selectedExerciseIds
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
            // zstack with the add button at the bottom 16 with padding
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
                .tint(selectedEquipment == nil ? .accentColor : .gray)
                
                ForEach(ExerciseEquipment.commonEquipments, id: \.self) { eq in
                    Button(eq.displayName) {
                        selectedEquipment = eq
                    }
                    .buttonStyle(.bordered)
                    .tint(selectedEquipment == eq ? .accentColor : .gray)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var exercisesList: some View {
        ZStack {
            List(filteredExercises, id: \.id) { exercise in
                row(for: exercise)
            }
            .listStyle(.insetGrouped)
            
            VStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Add \(selectedExerciseIds.count) exercise(s)")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 64)
            }
        }
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
            if selectedExerciseIds.contains(exercise.id) {
                Image(systemName: "checkmark")
                    .foregroundStyle(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let idx = selectedExerciseIds.firstIndex(of: exercise.id) {
                selectedExerciseIds.remove(at: idx)
            } else {
                selectedExerciseIds.append(exercise.id)
            }
        }
    }
}

#Preview {
    ExercisePickerView(selectedExerciseIds: Binding(get: { [] }, set: { _ in }))
        .modelContainer(for: [Exercise.self, ExerciseSet.self])
}
