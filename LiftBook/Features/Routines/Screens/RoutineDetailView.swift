//
//  RoutineDetailView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftData
import SwiftUI

struct RoutineDetailView: View {
    @Environment(\.routineService) private var routineService
    @Environment(\.modelContext) private var modelContext
    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue

    let routineID: UUID
    let onStartRoutine: (UUID) -> Void
    private let startsInEditing: Bool
    @Query private var routines: [RoutineTemplate]
    @Query(sort: \Exercise.name) private var exerciseLibrary: [Exercise]

    @State private var isEditing = false
    @State private var routineDraft = RoutineDraft()
    @State private var isShowingExerciseSelection = false
    @State private var hasAppliedInitialEditing = false
    @State private var saveError: RoutineDetailSaveError?

    init(
        routineID: UUID,
        startsInEditing: Bool = false,
        onStartRoutine: @escaping (UUID) -> Void = { _ in }
    ) {
        self.routineID = routineID
        self.startsInEditing = startsInEditing
        self.onStartRoutine = onStartRoutine
        let routineIdentifier = routineID
        _routines = Query(filter: #Predicate<RoutineTemplate> { routine in
            routine.id == routineIdentifier
        })
    }

    private var routine: RoutineTemplate? {
        routines.first
    }

    private var canSaveDraft: Bool {
        routineDraft.canSave
    }

    private var draftExerciseIDs: Set<String> {
        routineDraft.exerciseIDs
    }

    private var preferredWeightUnit: WeightUnit {
        WeightUnit(rawValue: preferredWeightUnitRawValue) ?? .kilograms
    }

    var body: some View {
        Group {
            if let routine {
                List {
                    Section {
                        if isEditing {
                            TextField("Routine name", text: $routineDraft.name)
                                .textInputAutocapitalization(.words)
                        } else {
                            RoutineDetailSummaryCard(
                                title: routine.name,
                                summary: RoutineDetailFormatter.routineSummaryText(for: routine),
                                onStart: { startWorkout(from: routine) }
                            )
                            .listRowInsets(
                                LBCardLayout.listRowInsets(top: 8, bottom: 14)
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }

                    Section("Exercises") {
                        if isEditing {
                            ForEach($routineDraft.exercises) { exercise in
                                RoutineDraftExerciseCard(
                                    exercise: exercise,
                                    showsSubtitle: false,
                                    onDelete: { deleteDraftExercise(exercise.wrappedValue) }
                                )
                                .listRowInsets(
                                    LBCardLayout.listRowInsets(top: 8, bottom: 8)
                                )
                                .listRowBackground(Color.clear)
                            }
                        } else {
                            ForEach(routine.sortedExercises) { exercise in
                                RoutineDetailExerciseCard(
                                    exercise: exercise,
                                    subtitle: RoutineDetailFormatter.exerciseSubtitle(
                                        for: exercise,
                                        in: exerciseLibrary
                                    )
                                )
                                    .listRowInsets(
                                        LBCardLayout.listRowInsets(top: 12, bottom: 12)
                                    )
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }

                    if isEditing {
                        Section {
                            Button(action: showExerciseSelection) {
                                Label("Add Exercise", systemImage: "plus.circle.fill")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(LBColor.background)
            } else {
                ContentUnavailableView(
                    "Routine Not Found",
                    systemImage: "list.bullet.rectangle",
                    description: Text("This routine may have been deleted.")
                )
            }
        }
        .navigationTitle(isEditing ? "Edit Routine" : routine?.name ?? "Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let routine {
                if isEditing {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel", action: cancelEditing)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            saveDraft(to: routine)
                        }
                        .disabled(!canSaveDraft)
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Edit") {
                            beginEditing(routine)
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $isShowingExerciseSelection) {
            ExerciseSelectionView(existingExerciseIDs: draftExerciseIDs) { exercises in
                addDraftExercises(exercises)
            }
        }
        .alert(item: $saveError) { error in
            Alert(
                title: Text("Could Not Save Routine"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear(perform: applyInitialEditingIfNeeded)
        .onChange(of: routine?.id) {
            applyInitialEditingIfNeeded()
        }
    }

    private func beginEditing(_ routine: RoutineTemplate) {
        routineDraft = RoutineDraft(routine: routine, weightUnit: preferredWeightUnit)
        isEditing = true
    }

    private func applyInitialEditingIfNeeded() {
        guard startsInEditing, !hasAppliedInitialEditing, let routine else {
            return
        }

        hasAppliedInitialEditing = true
        beginEditing(routine)
    }

    private func cancelEditing() {
        routineDraft = RoutineDraft()
        isShowingExerciseSelection = false
        isEditing = false
    }

    private func showExerciseSelection() {
        isShowingExerciseSelection = true
    }

    @MainActor
    private func addDraftExercises(_ exercises: [Exercise]) {
        routineDraft.addExercises(exercises)
    }

    private func deleteDraftExercise(_ exercise: RoutineExerciseDraft) {
        routineDraft.deleteExercise(exercise)
    }

    private func startWorkout(from routine: RoutineTemplate) {
        onStartRoutine(routine.id)
    }

    private func saveDraft(to routine: RoutineTemplate) {
        guard canSaveDraft else {
            return
        }

        do {
            try routineService.update(
                routine,
                with: routineDraft,
                weightUnit: preferredWeightUnit,
                in: modelContext
            )
            routineDraft = RoutineDraft()
            isEditing = false
        } catch {
            saveError = RoutineDetailSaveError(message: error.localizedDescription)
        }
    }
}

#Preview {
    NavigationStack {
        RoutineDetailView(routineID: UUID())
    }
    .modelContainer(
        for: [
            Exercise.self,
            RoutineTemplate.self,
            RoutineTemplateExercise.self,
            RoutineTemplateSet.self
        ],
        inMemory: true
    )
}
