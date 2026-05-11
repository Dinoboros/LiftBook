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
                                summary: routineSummaryText(for: routine),
                                onStart: { startWorkout(from: routine) }
                            )
                            .listRowInsets(
                                EdgeInsets(top: 8, leading: 16, bottom: 14, trailing: 16)
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
                                    EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                )
                                .listRowBackground(Color.clear)
                            }
                        } else {
                            ForEach(sortedExercises(for: routine)) { exercise in
                                RoutineDetailExerciseCard(
                                    exercise: exercise,
                                    subtitle: exerciseSubtitle(for: exercise)
                                )
                                    .listRowInsets(
                                        EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
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

    private func sortedExercises(for routine: RoutineTemplate) -> [RoutineTemplateExercise] {
        routine.sortedExercises
    }

    private func routineSummaryText(for routine: RoutineTemplate) -> String {
        "\(exerciseCountText(for: routine)) · \(setCountText(for: routine))"
    }

    private func exerciseCountText(for routine: RoutineTemplate) -> String {
        let count = routine.exercises.count

        if count == 1 {
            return "1 exercise"
        }

        return "\(count) exercises"
    }

    private func setCountText(for routine: RoutineTemplate) -> String {
        let count = sortedExercises(for: routine).reduce(0) { partialResult, exercise in
            partialResult + exercise.targetSetCount
        }

        if count == 1 {
            return "1 set"
        }

        return "\(count) sets"
    }

    private func exerciseSubtitle(for routineExercise: RoutineTemplateExercise) -> String? {
        guard let exercise = exerciseLibrary.first(where: { $0.id == routineExercise.exerciseID }) else {
            return nil
        }

        var parts: [String] = []

        if !exercise.primaryMuscles.isEmpty {
            parts.append(exercise.primaryMuscles.joined(separator: ", ").capitalized)
        } else if !exercise.category.isEmpty {
            parts.append(exercise.category.capitalized)
        }

        if let equipment = exercise.equipment.first(where: { !$0.isEmpty }) {
            parts.append(equipment.capitalized)
        }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
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

    private func startWorkout(from routine: RoutineTemplate) {
        onStartRoutine(routine.id)
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

private struct RoutineDetailSummaryCard: View {
    let title: String
    let summary: String
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            Button(action: onStart) {
                Label("Start Workout", systemImage: "play.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(LBColor.workoutStart)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Start \(title)")
        }
        .padding(18)
        .lbCardSurface()
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
        for: [
            Exercise.self,
            RoutineTemplate.self,
            RoutineTemplateExercise.self,
            RoutineTemplateSet.self
        ],
        inMemory: true
    )
}
