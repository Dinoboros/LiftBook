//
//  ExerciseSelectionView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import SwiftData
import SwiftUI

struct ExerciseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.exerciseService) private var exerciseService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]
    @Query(sort: \RoutineTemplate.createdAt) private var routines: [RoutineTemplate]

    let existingExerciseIDs: Set<String>
    let onAdd: ([Exercise]) -> Void

    @State private var searchText = ""
    @State private var exerciseFilter = ExerciseLibraryFilter()
    @State private var isShowingFilterSheet = false
    @State private var path: [ExerciseSelectionRoute] = []
    @State private var selectedExerciseIDs: [String] = []
    @State private var exerciseEditorMode: CustomExerciseEditorMode?
    @State private var exerciseDeletionRequest: CustomExerciseDeletionRequest?
    @State private var exerciseError: ExerciseManagementError?

    private var filteredExercises: [Exercise] {
        ExerciseSearchFilter.filteredExercises(
            from: exercises,
            matching: searchText,
            filter: exerciseFilter
        )
    }

    private var filterOptions: ExerciseLibraryFilterOptions {
        ExerciseLibraryFilterOptions.make(from: exercises)
    }

    private var selectedExercises: [Exercise] {
        let exercisesByID = Dictionary(uniqueKeysWithValues: exercises.map { ($0.id, $0) })

        return selectedExerciseIDs.compactMap { exercisesByID[$0] }
    }

    private var selectedExerciseIDSet: Set<String> {
        Set(selectedExerciseIDs)
    }

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if exercises.isEmpty {
                    ContentUnavailableView(
                        "No Exercises",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("The exercise library is not available.")
                    )
                } else {
                    exerciseSelectionContent
                }
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ExerciseSelectionRoute.self, destination: destination)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create", action: createCustomExercise)
                        .accessibilityLabel("Create custom exercise")
                }
            }
            .lbKeyboardDismissToolbar()
            .safeAreaInset(edge: .bottom) {
                if !selectedExerciseIDs.isEmpty {
                    ExerciseSelectionAddButton(
                        title: addButtonTitle,
                        action: addSelectedExercises
                    )
                }
            }
            .animation(.snappy(duration: 0.22), value: selectedExerciseIDs.isEmpty)
            .sheet(item: $exerciseEditorMode) { mode in
                CustomExerciseEditorView(mode: mode)
            }
            .sheet(isPresented: $isShowingFilterSheet) {
                ExerciseFilterSheet(
                    initialFilter: exerciseFilter,
                options: filterOptions,
                onApply: { exerciseFilter = $0 }
            )
        }
            .alert(
                exerciseDeletionRequest?.confirmationTitle ?? "Delete Custom Exercise?",
                isPresented: isShowingDeleteConfirmation,
                presenting: exerciseDeletionRequest
            ) { request in
                Button("Delete Exercise", role: .destructive) {
                    deleteRequestedCustomExercise(request)
                }
                Button("Cancel", role: .cancel) {}
            } message: { request in
                Text(request.confirmationMessage)
            }
            .alert(item: $exerciseError) { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private var exerciseSelectionContent: some View {
        VStack(spacing: 12) {
            ExerciseFilterSearchHeader(
                searchText: $searchText,
                filter: $exerciseFilter,
                onShowFilters: { isShowingFilterSheet = true }
            )
            .padding(.horizontal, 20)
            .padding(.top, 8)

            if filteredExercises.isEmpty {
                ExerciseFilterNoResultsView(
                    searchText: searchText,
                    isFilterActive: exerciseFilter.isActive
                )
            } else {
                List(filteredExercises) { exercise in
                    exerciseSelectionRow(for: exercise)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if exercise.isCustom {
                                Button {
                                    editCustomExercise(exercise)
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)

                                Button(role: .destructive) {
                                    requestDeleteCustomExercise(exercise)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    private func exerciseSelectionRow(for exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            Button {
                toggleExercise(exercise)
            } label: {
                ExerciseLibraryRow(
                    exercise: exercise,
                    isSelected: selectedExerciseIDSet.contains(exercise.id),
                    isAlreadyAdded: existingExerciseIDs.contains(exercise.id),
                    showsSelectionState: true
                )
            }
            .buttonStyle(.plain)
            .disabled(existingExerciseIDs.contains(exercise.id))

            Button {
                showExerciseDetail(exercise)
            } label: {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Show details for \(exercise.name)")
        }
    }

    @ViewBuilder
    private func destination(for route: ExerciseSelectionRoute) -> some View {
        switch route {
        case .exerciseDetail(let exerciseID):
            if let exercise = exercises.first(where: { $0.id == exerciseID }) {
                ExerciseDetailView(exercise: exercise)
            } else {
                ContentUnavailableView(
                    "Exercise Not Found",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text("This exercise may have been removed.")
                )
            }
        }
    }

    private var isShowingDeleteConfirmation: Binding<Bool> {
        Binding {
            exerciseDeletionRequest != nil
        } set: { isPresented in
            if !isPresented {
                exerciseDeletionRequest = nil
            }
        }
    }

    private var addButtonTitle: String {
        if selectedExerciseIDs.count == 1 {
            return "Add 1 Exercise"
        }

        return "Add \(selectedExerciseIDs.count) Exercises"
    }

    private func toggleExercise(_ exercise: Exercise) {
        guard !existingExerciseIDs.contains(exercise.id) else {
            return
        }

        if selectedExerciseIDSet.contains(exercise.id) {
            selectedExerciseIDs.removeAll { $0 == exercise.id }
        } else {
            selectedExerciseIDs.append(exercise.id)
        }
    }

    private func addSelectedExercises() {
        onAdd(selectedExercises)
        dismiss()
    }

    private func showExerciseDetail(_ exercise: Exercise) {
        path.append(.exerciseDetail(exercise.id))
    }

    private func createCustomExercise() {
        exerciseEditorMode = .create()
    }

    private func editCustomExercise(_ exercise: Exercise) {
        guard exercise.isCustom else {
            return
        }

        exerciseEditorMode = .edit(exercise)
    }

    private func requestDeleteCustomExercise(_ exercise: Exercise) {
        guard exercise.isCustom else {
            return
        }

        exerciseDeletionRequest = CustomExerciseDeletionRequest(
            exerciseID: exercise.id,
            exerciseName: exercise.name,
            isUsedInRoutines: isExerciseUsedInRoutines(exercise)
        )
    }

    private func deleteRequestedCustomExercise(_ request: CustomExerciseDeletionRequest) {
        defer {
            self.exerciseDeletionRequest = nil
        }

        guard let exercise = exercises.first(where: { $0.id == request.exerciseID }) else {
            return
        }

        do {
            selectedExerciseIDs.removeAll { $0 == exercise.id }
            try exerciseService.deleteCustomExercise(exercise, in: modelContext)
        } catch {
            exerciseError = ExerciseManagementError(
                title: "Could Not Delete Exercise",
                message: error.localizedDescription
            )
        }
    }

    private func isExerciseUsedInRoutines(_ exercise: Exercise) -> Bool {
        routines.contains { routine in
            routine.exercises.contains { routineExercise in
                routineExercise.exerciseID == exercise.id
            }
        }
    }
}

private enum ExerciseSelectionRoute: Hashable {
    case exerciseDetail(String)
}

#Preview {
    ExerciseSelectionView(existingExerciseIDs: []) { _ in }
        .modelContainer(for: [Exercise.self], inMemory: true)
}
