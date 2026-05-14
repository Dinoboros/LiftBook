//
//  ExerciseLibraryView.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import SwiftData
import SwiftUI

struct ExerciseLibraryView: View {
    @Environment(\.exerciseService) private var exerciseService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]

    @State private var searchText = ""
    @State private var exerciseFilter = ExerciseLibraryFilter()
    @State private var isShowingFilterSheet = false
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

    var body: some View {
        Group {
            if exercises.isEmpty {
                ContentUnavailableView(
                    "No Exercises",
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text("The exercise library is not available.")
                )
            } else {
                exerciseLibraryContent
            }
        }
        .navigationTitle("Exercise Library")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create", action: createCustomExercise)
                    .accessibilityLabel("Create custom exercise")
            }
        }
        .lbKeyboardDismissToolbar()
        .sheet(item: $exerciseEditorMode) { mode in
            CustomExerciseEditorView(mode: mode)
        }
        .sheet(isPresented: $isShowingFilterSheet) {
            ExerciseFilterSheet(
                initialFilter: exerciseFilter,
                options: filterOptions,
                onApply: { exerciseFilter = $0 }
            )
            .presentationSizing(.fitted)
        }
        .confirmationDialog(
            "Delete Custom Exercise?",
            isPresented: isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Exercise", role: .destructive, action: deleteRequestedCustomExercise)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(deleteConfirmationMessage)
        }
        .alert(item: $exerciseError) { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var exerciseLibraryContent: some View {
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
                    NavigationLink {
                        destination(for: .exerciseDetail(exercise.id))
                    } label: {
                        ExerciseLibraryRow(exercise: exercise)
                    }
                    .accessibilityLabel(exercise.name)
                    .accessibilityIdentifier("exerciseLibraryRow-\(exercise.id)")
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

    @ViewBuilder
    private func destination(for route: ExerciseLibraryRoute) -> some View {
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

    private var deleteConfirmationMessage: String {
        guard let exerciseDeletionRequest else {
            return "This custom exercise will be removed from the library."
        }

        return "This will remove \"\(exerciseDeletionRequest.exerciseName)\" from the exercise library."
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
            exerciseName: exercise.name
        )
    }

    private func deleteRequestedCustomExercise() {
        guard let exerciseDeletionRequest else {
            return
        }

        defer {
            self.exerciseDeletionRequest = nil
        }

        guard let exercise = exercises.first(where: { $0.id == exerciseDeletionRequest.exerciseID }) else {
            return
        }

        do {
            try exerciseService.deleteCustomExercise(exercise, in: modelContext)
        } catch {
            exerciseError = ExerciseManagementError(
                title: "Could Not Delete Exercise",
                message: error.localizedDescription
            )
        }
    }
}

private enum ExerciseLibraryRoute: Hashable {
    case exerciseDetail(String)
}

#Preview("Seeded Library") {
    ExerciseLibraryPreview.view
}

private enum ExerciseLibraryPreview {
    @MainActor
    static var view: some View {
        let container = try! LiftBookPersistence.makeModelContainer(isStoredInMemoryOnly: true)
        let context = container.mainContext

        context.insert(
            Exercise(
                id: "close-grip-bench-press",
                name: "Close-Grip Bench Press",
                category: "strength",
                exerciseDescription: "Flat bench press performed with a close grip on a barbell",
                equipment: ["barbell", "bench"],
                instructions: [
                    "Lie back on a flat bench and hold the bar over your chest.",
                    "Lower the bar while keeping elbows close.",
                    "Press the bar back to the starting position."
                ],
                primaryMuscles: ["triceps"],
                secondaryMuscles: ["chest", "shoulders"],
                videoURL: "https://www.youtube.com/watch?v=XEnAUu6WtSw"
            )
        )
        context.insert(
            Exercise(
                id: "custom-tempo-push-up",
                name: "Tempo Push-Up",
                category: "strength",
                primaryMuscles: ["chest"],
                isCustom: true
            )
        )
        try? context.save()

        return NavigationStack {
            ExerciseLibraryView()
        }
        .modelContainer(container)
    }
}
