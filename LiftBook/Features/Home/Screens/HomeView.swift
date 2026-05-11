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

    private var workoutHistory: [WorkoutSession] {
        completedWorkoutSessions
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
                HomePrimaryActionsSection(
                    rowInsets: cardRowInsets,
                    onStartEmptyWorkout: startEmptyWorkout,
                    onCreateRoutine: createRoutine
                )

                HomeRoutinesSection(
                    routines: routines,
                    rowInsets: cardRowInsets,
                    onOpen: openRoutineDetail,
                    onStart: startWorkout,
                    onEdit: editRoutine,
                    onDelete: requestDeleteRoutine
                )

                HomeHistorySection(
                    workouts: workoutHistory,
                    rowInsets: cardRowInsets,
                    onOpen: openWorkoutHistory
                )
            }
            .scrollContentBackground(.hidden)
            .background(LBColor.background)
            .navigationTitle("Home")
            .navigationDestination(for: HomeRoute.self, destination: destination)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: openSettings) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
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
        case .settings:
            SettingsView()
        case .routineEditor:
            RoutineEditorView()
        case .routineDetail(let routineID):
            RoutineDetailView(
                routineID: routineID,
                onStartRoutine: startWorkoutFromRoutineDetail
            )
        case .routineEdit(let routineID):
            RoutineDetailView(
                routineID: routineID,
                startsInEditing: true,
                onStartRoutine: startWorkoutFromRoutineDetail
            )
        case .workoutHistoryDetail(let workoutSessionID):
            WorkoutHistoryDetailView(workoutSessionID: workoutSessionID)
        }
    }

    private func startEmptyWorkout() {
        startWorkout(.empty(UUID(), returnsHomeFirst: false))
    }

    private func startWorkout(from routine: RoutineTemplate) {
        startWorkout(.routine(routine.id, returnsHomeFirst: false))
    }

    private func startWorkoutFromRoutineDetail(_ routineID: UUID) {
        startWorkout(.routine(routineID, returnsHomeFirst: true))
    }

    private func createRoutine() {
        path.append(.routineEditor)
    }

    private func openSettings() {
        path.append(.settings)
    }

    private func openRoutineDetail(_ routine: RoutineTemplate) {
        path.append(.routineDetail(routine.id))
    }

    private func editRoutine(_ routine: RoutineTemplate) {
        path.append(.routineEdit(routine.id))
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
        let shouldReturnHomeFirst = pendingWorkoutStart?.shouldReturnHomeFirst ?? false
        pendingWorkoutStart = nil

        guard let activeWorkout else {
            return
        }

        presentWorkout(activeWorkout, returningHomeFirst: shouldReturnHomeFirst)
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
            case .empty(_, _):
                workout = try workoutService.createEmptyWorkout(in: modelContext)
            case .routine(let routineID, _):
                guard let routine = routines.first(where: { $0.id == routineID }) else {
                    homeError = HomeError(
                        title: "Could Not Start Workout",
                        message: "This routine may have been deleted."
                    )
                    return
                }

                workout = try workoutService.createWorkout(from: routine, in: modelContext)
            }

            presentWorkout(workout, returningHomeFirst: request.shouldReturnHomeFirst)
        } catch {
            homeError = HomeError(
                title: "Could Not Start Workout",
                message: error.localizedDescription
            )
        }
    }

    private func presentWorkout(_ workout: WorkoutSession, returningHomeFirst: Bool) {
        let presentation = ActiveWorkoutPresentation.session(workout.id)

        guard returningHomeFirst else {
            activeWorkoutPresentation = presentation
            return
        }

        path.removeAll()

        DispatchQueue.main.async {
            self.activeWorkoutPresentation = presentation
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

}

#Preview {
    HomeView()
        .modelContainer(
            for: [
                Exercise.self,
                RoutineTemplate.self,
                RoutineTemplateExercise.self,
                RoutineTemplateSet.self,
                WorkoutSession.self,
                WorkoutSessionExercise.self,
                WorkoutSet.self
            ],
            inMemory: true
        )
}
