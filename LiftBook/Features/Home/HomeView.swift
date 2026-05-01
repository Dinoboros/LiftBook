//
//  HomeView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import Foundation
import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.routineService) private var routineService
    @Environment(\.workoutService) private var workoutService

    @Query(sort: \RoutineTemplate.createdAt) private var routines: [RoutineTemplate]
    @Query(
        filter: #Predicate<WorkoutSession> { session in
            session.endedAt == nil
        },
        sort: \WorkoutSession.startedAt,
        order: .reverse
    ) private var activeWorkoutSessions: [WorkoutSession]
    @Query(
        filter: #Predicate<WorkoutSession> { session in
            session.endedAt != nil
        },
        sort: \WorkoutSession.startedAt,
        order: .reverse
    ) private var completedWorkoutSessions: [WorkoutSession]

    @State private var path: [HomeRoute] = []
    @State private var activeWorkoutPresentation: ActiveWorkoutPresentation?
    @State private var pendingWorkoutStart: WorkoutStartRequest?
    @State private var routineDeletionRequest: RoutineDeletionRequest?
    @State private var homeError: HomeError?

    private var activeWorkout: WorkoutSession? {
        activeWorkoutSessions.first
    }

    private var routineHistory: [WorkoutSession] {
        return completedWorkoutSessions
            .filter { workout in
                workout.sourceRoutineTemplateID != nil
            }
            .sorted {
                ($0.endedAt ?? $0.startedAt) > ($1.endedAt ?? $1.startedAt)
            }
    }

    private var isShowingActiveWorkoutConflict: Binding<Bool> {
        Binding {
            pendingWorkoutStart != nil
        } set: { isPresented in
            if !isPresented {
                pendingWorkoutStart = nil
            }
        }
    }

    private var isShowingRoutineDeleteConfirmation: Binding<Bool> {
        Binding {
            routineDeletionRequest != nil
        } set: { isPresented in
            if !isPresented {
                routineDeletionRequest = nil
            }
        }
    }

    private var routineDeletionMessage: String {
        guard let routineDeletionRequest else {
            return "This routine will be permanently deleted."
        }

        return "This will permanently delete \"\(routineDeletionRequest.routineName)\"."
    }

    private var cardRowInsets: EdgeInsets {
        EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4)
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    LBSplitActionControl(
                        leadingAction: LBSplitAction(
                            title: "Start Empty Workout",
                            systemImage: "plus.circle.fill",
                            action: startEmptyWorkout
                        ),
                        trailingAction: LBSplitAction(
                            title: "Create Routine",
                            systemImage: "doc.badge.plus",
                            action: createRoutine
                        )
                    )
                    .listRowInsets(
                        cardRowInsets
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }

                Section("Routines") {
                    if routines.isEmpty {
                        ContentUnavailableView(
                            "No Routines",
                            systemImage: "list.bullet.rectangle",
                            description: Text("Saved routines will appear here.")
                        )
                    } else {
                        ForEach(routines) { routine in
                            RoutineCard(
                                title: routine.name,
                                exerciseSummary: exerciseSummary(for: routine),
                                onStart: { startWorkout(from: routine) },
                                onEdit: { editRoutine(routine) },
                                onDuplicate: { duplicateRoutine(routine) },
                                onDelete: { requestDeleteRoutine(routine) }
                            )
                            .listRowInsets(
                                cardRowInsets
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }

                Section("History") {
                    if routineHistory.isEmpty {
                        ContentUnavailableView(
                            "No History",
                            systemImage: "clock.arrow.circlepath",
                            description: Text("Completed routines will appear here.")
                        )
                    } else {
                        ForEach(routineHistory) { workout in
                            Button {
                                openWorkoutHistory(workout)
                            } label: {
                                WorkoutHistoryCard(
                                    title: workout.name,
                                    exerciseSummary: exerciseSummary(for: workout),
                                    completedAtText: completedAtText(for: workout)
                                )
                            }
                            .buttonStyle(.plain)
                            .listRowInsets(
                                cardRowInsets
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(LBColor.background)
            .navigationTitle("Home")
            .navigationDestination(for: HomeRoute.self, destination: destination)
            .fullScreenCover(item: $activeWorkoutPresentation) { presentation in
                NavigationStack {
                    ActiveWorkoutView(workoutSessionID: presentation.workoutSessionID)
                }
            }
            .confirmationDialog(
                "Workout in Progress",
                isPresented: isShowingActiveWorkoutConflict,
                titleVisibility: .visible
            ) {
                Button("Resume Current Workout", action: resumeActiveWorkout)

                Button("Discard Current and Start New", role: .destructive) {
                    if let pendingWorkoutStart {
                        discardActiveWorkoutsAndStart(pendingWorkoutStart)
                    }
                }

                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You already have an active workout.")
            }
            .confirmationDialog(
                "Delete Routine?",
                isPresented: isShowingRoutineDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Routine", role: .destructive, action: deleteRequestedRoutine)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(routineDeletionMessage)
            }
            .alert(item: $homeError) { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .safeAreaInset(edge: .bottom) {
                if let activeWorkout {
                    ActiveWorkoutResumeCard(
                        workout: activeWorkout,
                        onResume: resumeActiveWorkout
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: HomeRoute) -> some View {
        switch route {
        case .routineEditor:
            RoutineEditorView()
        case .routineDetail(let routineID):
            RoutineDetailView(routineID: routineID, startsInEditing: true)
        case .workoutHistoryDetail(let workoutSessionID):
            WorkoutHistoryDetailView(workoutSessionID: workoutSessionID)
        }
    }

    private func startEmptyWorkout() {
        startWorkout(.empty(UUID()))
    }

    private func startWorkout(from routine: RoutineTemplate) {
        startWorkout(.routine(routine.id))
    }

    private func createRoutine() {
        path.append(.routineEditor)
    }

    private func editRoutine(_ routine: RoutineTemplate) {
        path.append(.routineDetail(routine.id))
    }

    private func openWorkoutHistory(_ workout: WorkoutSession) {
        path.append(.workoutHistoryDetail(workout.id))
    }

    private func startWorkout(_ request: WorkoutStartRequest) {
        guard activeWorkout == nil else {
            pendingWorkoutStart = request
            return
        }

        createAndPresentWorkout(for: request)
    }

    private func resumeActiveWorkout() {
        pendingWorkoutStart = nil

        guard let activeWorkout else {
            return
        }

        activeWorkoutPresentation = .session(activeWorkout.id)
    }

    private func discardActiveWorkoutsAndStart(_ request: WorkoutStartRequest) {
        pendingWorkoutStart = nil

        do {
            try workoutService.discard(activeWorkoutSessions, in: modelContext)
            createAndPresentWorkout(for: request)
        } catch {
            homeError = HomeError(
                title: "Could Not Start Workout",
                message: error.localizedDescription
            )
        }
    }

    private func createAndPresentWorkout(for request: WorkoutStartRequest) {
        do {
            let workout: WorkoutSession

            switch request {
            case .empty:
                workout = try workoutService.createEmptyWorkout(in: modelContext)
            case .routine(let routineID):
                guard let routine = routines.first(where: { $0.id == routineID }) else {
                    homeError = HomeError(
                        title: "Could Not Start Workout",
                        message: "This routine may have been deleted."
                    )
                    return
                }

                workout = try workoutService.createWorkout(from: routine, in: modelContext)
            }

            activeWorkoutPresentation = .session(workout.id)
        } catch {
            homeError = HomeError(
                title: "Could Not Start Workout",
                message: error.localizedDescription
            )
        }
    }

    private func requestDeleteRoutine(_ routine: RoutineTemplate) {
        routineDeletionRequest = RoutineDeletionRequest(
            routineID: routine.id,
            routineName: routine.name
        )
    }

    private func deleteRequestedRoutine() {
        guard let routineDeletionRequest else {
            return
        }

        defer {
            self.routineDeletionRequest = nil
        }

        guard let routine = routines.first(where: { $0.id == routineDeletionRequest.routineID }) else {
            return
        }

        do {
            try routineService.delete(routine, in: modelContext)
        } catch {
            homeError = HomeError(
                title: "Could Not Delete Routine",
                message: error.localizedDescription
            )
        }
    }

    private func duplicateRoutine(_ routine: RoutineTemplate) {
        do {
            try routineService.duplicate(routine, in: modelContext)
        } catch {
            homeError = HomeError(
                title: "Could Not Duplicate Routine",
                message: error.localizedDescription
            )
        }
    }

    private func sortedExercises(for routine: RoutineTemplate) -> [RoutineTemplateExercise] {
        routine.sortedExercises
    }

    private func exerciseSummary(for routine: RoutineTemplate) -> String {
        let exerciseNames = sortedExercises(for: routine)
            .prefix(3)
            .map(\.exerciseName)

        guard !exerciseNames.isEmpty else {
            return "No exercises"
        }

        return exerciseNames.joined(separator: ", ")
    }

    private func exerciseSummary(for workout: WorkoutSession) -> String {
        let exerciseNames = sortedExercises(for: workout)
            .prefix(3)
            .map(\.exerciseName)

        guard !exerciseNames.isEmpty else {
            return "No exercises"
        }

        return exerciseNames.joined(separator: ", ")
    }

    private func sortedExercises(for workout: WorkoutSession) -> [WorkoutSessionExercise] {
        workout.sortedExercises
    }

    private func completedAtText(for workout: WorkoutSession) -> String {
        guard let endedAt = workout.endedAt else {
            return "Date unavailable"
        }

        return endedAt.formatted(date: .abbreviated, time: .shortened)
    }
}

private enum ActiveWorkoutPresentation: Identifiable {
    case session(UUID)

    var id: UUID {
        switch self {
        case .session(let workoutSessionID):
            return workoutSessionID
        }
    }

    var workoutSessionID: UUID {
        switch self {
        case .session(let workoutSessionID):
            return workoutSessionID
        }
    }
}

private enum WorkoutStartRequest: Identifiable {
    case empty(UUID)
    case routine(UUID)

    var id: UUID {
        switch self {
        case .empty(let id), .routine(let id):
            return id
        }
    }
}

private struct RoutineDeletionRequest {
    let routineID: UUID
    let routineName: String
}

private struct HomeError: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

private struct ActiveWorkoutResumeCard: View {
    let workout: WorkoutSession
    let onResume: () -> Void

    private var exerciseCountText: String {
        let count = workout.exercises.count

        if count == 1 {
            return "1 exercise"
        }

        return "\(count) exercises"
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)

                Text("\(exerciseCountText) - Started \(workout.startedAt.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Resume", action: onResume)
                .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(
            for: [
                Exercise.self,
                RoutineTemplate.self,
                RoutineTemplateExercise.self,
                WorkoutSession.self,
                WorkoutSessionExercise.self,
                WorkoutSet.self
            ],
            inMemory: true
        )
}
