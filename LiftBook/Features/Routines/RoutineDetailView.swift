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

    let routineID: UUID
    @Query private var routines: [RoutineTemplate]

    @State private var isEditing = false
    @State private var routineDraft = RoutineDetailDraft()
    @State private var isShowingExerciseSelection = false
    @State private var saveError: RoutineDetailSaveError?

    init(routineID: UUID) {
        self.routineID = routineID
        let routineIdentifier = routineID
        _routines = Query(filter: #Predicate<RoutineTemplate> { routine in
            routine.id == routineIdentifier
        })
    }

    private var routine: RoutineTemplate? {
        routines.first
    }

    private var trimmedDraftName: String {
        routineDraft.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSaveDraft: Bool {
        !trimmedDraftName.isEmpty && !routineDraft.exercises.isEmpty
    }

    private var draftExerciseIDs: Set<String> {
        Set(routineDraft.exercises.map(\.exerciseID))
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
                                RoutineDetailEditableExerciseCard(
                                    exercise: exercise,
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
    }

    private func sortedExercises(for routine: RoutineTemplate) -> [RoutineTemplateExercise] {
        routine.exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    private func exerciseCountText(for routine: RoutineTemplate) -> String {
        let count = routine.exercises.count

        if count == 1 {
            return "1 exercise"
        }

        return "\(count) exercises"
    }

    private func beginEditing(_ routine: RoutineTemplate) {
        routineDraft = RoutineDetailDraft(routine: routine)
        isEditing = true
    }

    private func cancelEditing() {
        routineDraft = RoutineDetailDraft()
        isShowingExerciseSelection = false
        isEditing = false
    }

    private func showExerciseSelection() {
        isShowingExerciseSelection = true
    }

    private func addDraftExercises(_ exercises: [Exercise]) {
        let newDrafts = exercises
            .filter { !draftExerciseIDs.contains($0.id) }
            .map(RoutineDetailExerciseDraft.init)

        routineDraft.exercises.append(contentsOf: newDrafts)
    }

    private func deleteDraftExercise(_ exercise: RoutineDetailExerciseDraft) {
        routineDraft.exercises.removeAll { $0.id == exercise.id }
    }

    private func saveDraft(to routine: RoutineTemplate) {
        guard canSaveDraft else {
            return
        }

        routine.name = trimmedDraftName
        routine.updatedAt = .now

        let existingExercises = routine.exercises
        for exercise in existingExercises {
            modelContext.delete(exercise)
        }
        routine.exercises.removeAll()

        for (index, exercise) in routineDraft.exercises.enumerated() {
            let routineExercise = RoutineTemplateExercise(
                exerciseID: exercise.exerciseID,
                exerciseName: exercise.exerciseName,
                sortOrder: index,
                targetSets: exercise.targetSets
            )

            modelContext.insert(routineExercise)
            routine.exercises.append(routineExercise)
        }

        do {
            try modelContext.save()
            routineDraft = RoutineDetailDraft()
            isEditing = false
        } catch {
            saveError = RoutineDetailSaveError(message: error.localizedDescription)
        }
    }
}

private struct RoutineDetailDraft {
    var name = ""
    var exercises: [RoutineDetailExerciseDraft] = []

    init() {}

    init(routine: RoutineTemplate) {
        name = routine.name
        exercises = routine.exercises
            .sorted { $0.sortOrder < $1.sortOrder }
            .map(RoutineDetailExerciseDraft.init)
    }
}

private struct RoutineDetailExerciseDraft: Identifiable, Equatable {
    let id: UUID
    let exerciseID: String
    let exerciseName: String
    var sets: [RoutineDetailSetDraft]

    var targetSets: Int {
        sets.count
    }

    init(exercise: RoutineTemplateExercise) {
        id = exercise.id
        exerciseID = exercise.exerciseID
        exerciseName = exercise.exerciseName
        sets = (0..<max(exercise.targetSets, 1)).map { _ in RoutineDetailSetDraft() }
    }

    init(exercise: Exercise) {
        id = UUID()
        exerciseID = exercise.id
        exerciseName = exercise.name
        sets = [
            RoutineDetailSetDraft(),
            RoutineDetailSetDraft(),
            RoutineDetailSetDraft()
        ]
    }
}

private struct RoutineDetailSetDraft: Identifiable, Equatable {
    let id = UUID()
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

private struct RoutineDetailEditableExerciseCard: View {
    @Binding var exercise: RoutineDetailExerciseDraft
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                Text(exercise.exerciseName)
                    .font(.title3.weight(.semibold))

                Spacer()

                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Exercise options")
            }

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

                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    RoutineDetailSetRow(
                        setNumber: index + 1,
                        canDelete: exercise.sets.count > 1,
                        onDelete: { deleteSet(id: set.id) }
                    )
                }
            }

            Button(action: addSet) {
                Label("Add set", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
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

    private func addSet() {
        exercise.sets.append(RoutineDetailSetDraft())
    }

    private func deleteSet(id: UUID) {
        guard exercise.sets.count > 1 else {
            return
        }

        exercise.sets.removeAll { $0.id == id }
    }
}

private struct RoutineDetailSetRow: View {
    let setNumber: Int
    var canDelete = false
    var onDelete: (() -> Void)?

    @State private var offset: CGFloat = 0

    private let deleteButtonWidth: CGFloat = 72
    private let revealThreshold: CGFloat = 24

    private var isDeleteRevealed: Bool {
        offset < 0
    }

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
        ZStack(alignment: .trailing) {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: deleteButtonWidth)
                        .frame(maxHeight: .infinity)
                        .background(.red)
                }
                .buttonStyle(.plain)
                .opacity(canDelete && isDeleteRevealed ? 1 : 0)
                .accessibilityLabel("Delete set \(setNumber)")
            }

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
            .offset(x: canDelete ? offset : 0)
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        guard canDelete else {
                            return
                        }

                        offset = max(-deleteButtonWidth, min(0, value.translation.width))
                    }
                    .onEnded { value in
                        guard canDelete else {
                            return
                        }

                        if value.translation.width < -revealThreshold {
                            offset = -deleteButtonWidth
                        } else {
                            offset = 0
                        }
                    }
            )
            .animation(.snappy(duration: 0.2), value: offset)
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
