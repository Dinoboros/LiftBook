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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.routineService) private var routineService

    let routineID: UUID
    private let startsInEditing: Bool
    @Query private var routines: [RoutineTemplate]

    @State private var isEditing = false
    @State private var routineDraft = RoutineDraft()
    @State private var isShowingExerciseSelection = false
    @State private var hasAppliedInitialEditing = false
    @State private var saveError: RoutineDetailSaveError?

    init(routineID: UUID, startsInEditing: Bool = false) {
        self.routineID = routineID
        self.startsInEditing = startsInEditing
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

    var body: some View {
        Group {
            if let routine {
                List {
                    Section {
                        if isEditing {
                            TextField("Routine name", text: $routineDraft.name)
                                .textInputAutocapitalization(.words)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(routine.name)
                                    .font(.headline)

                                Text(exerciseCountText(for: routine))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Section("Exercises") {
                        if isEditing {
                            ForEach($routineDraft.exercises) { exercise in
                                RoutineDraftExerciseCard(
                                    exercise: exercise,
                                    showsSubtitle: false,
                                    showsSetInputs: false,
                                    onDelete: { deleteDraftExercise(exercise.wrappedValue) }
                                )
                                .listRowInsets(
                                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                )
                                .listRowBackground(Color.clear)
                            }
                        } else {
                            ForEach(sortedExercises(for: routine)) { exercise in
                                RoutineDetailExerciseCard(exercise: exercise)
                                    .listRowInsets(
                                        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                    )
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

    private func sortedExercises(for routine: RoutineTemplate) -> [RoutineTemplateExercise] {
        routine.sortedExercises
    }

    private func exerciseCountText(for routine: RoutineTemplate) -> String {
        let count = routine.exercises.count

        if count == 1 {
            return "1 exercise"
        }

        return "\(count) exercises"
    }

    private func beginEditing(_ routine: RoutineTemplate) {
        routineDraft = RoutineDraft(routine: routine)
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

    private func saveDraft(to routine: RoutineTemplate) {
        guard canSaveDraft else {
            return
        }

        do {
            try routineService.update(routine, with: routineDraft, in: modelContext)
            routineDraft = RoutineDraft()
            isEditing = false
        } catch {
            saveError = RoutineDetailSaveError(message: error.localizedDescription)
        }
    }
}

private struct RoutineDetailExerciseCard: View {
    let exercise: RoutineTemplateExercise

    private var setNumbers: [Int] {
        Array(1...max(exercise.targetSets, 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(exercise.exerciseName)
                .font(.title3.weight(.semibold))

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Text("Set #")
                        .frame(maxWidth: .infinity)
                    Text("Reps")
                        .frame(maxWidth: .infinity)
                    Text("Weight")
                        .frame(maxWidth: .infinity)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                ForEach(setNumbers, id: \.self) { setNumber in
                    RoutineDetailSetRow(setNumber: setNumber)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

private struct RoutineDetailSetRow: View {
    let setNumber: Int

    private var rowGradientColors: [Color] {
        if setNumber.isMultiple(of: 2) {
            return [
                .teal.opacity(0.14),
                .cyan.opacity(0.07)
            ]
        }

        return [
            .indigo.opacity(0.13),
            .blue.opacity(0.06)
        ]
    }

    private var rowGradient: LinearGradient {
        LinearGradient(
            colors: rowGradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(setNumber)")
                .frame(maxWidth: .infinity)

            Text("-")
                .frame(maxWidth: .infinity)

            Text("-")
                .frame(maxWidth: .infinity)
        }
        .font(.body)
        .padding(.vertical, 4)
        .background {
            Color(.secondarySystemGroupedBackground)
            rowGradient
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

private struct RoutineDetailSaveError: Identifiable {
    let id = UUID()
    let message: String
}

#Preview {
    NavigationStack {
        RoutineDetailView(routineID: UUID())
    }
    .modelContainer(
        for: [Exercise.self, RoutineTemplate.self, RoutineTemplateExercise.self],
        inMemory: true
    )
}
