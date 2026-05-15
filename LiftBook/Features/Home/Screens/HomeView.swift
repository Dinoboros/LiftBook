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
    @Environment(\.restTimerNotificationService) private var restTimerNotificationService
    @Environment(\.restTimerNotificationCoordinator) private var restTimerNotificationCoordinator
    @Environment(\.scenePhase) private var scenePhase

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
    @State private var workoutHistoryDeletionRequest: WorkoutHistoryDeletionRequest?
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

    private var cardRowInsets: EdgeInsets {
        LBCardLayout.listRowInsets(top: 10, bottom: 10)
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
                    onOpen: openWorkoutHistory,
                    onDelete: requestDeleteWorkoutHistory
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
            .modifier(
                HomeConfirmationAlerts(
                    pendingWorkoutStart: $pendingWorkoutStart,
                    routineDeletionRequest: $routineDeletionRequest,
                    workoutHistoryDeletionRequest: $workoutHistoryDeletionRequest,
                    onResumeActiveWorkout: resumeActiveWorkout,
                    onDiscardActiveWorkoutsAndStart: discardActiveWorkoutsAndStart,
                    onDeleteRoutine: deleteRequestedRoutine,
                    onDeleteWorkoutHistory: deleteRequestedWorkoutHistory
                )
            )
            .alert(item: $homeError) { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .safeAreaInset(edge: .bottom) {
                if activeWorkoutPresentation == nil, let activeWorkout {
                    ActiveWorkoutResumeCard(
                        workout: activeWorkout,
                        onResume: resumeActiveWorkout
                    )
                }
            }
            .onAppear {
                clearExpiredRestTimersIfNeeded()
                presentRequestedWorkoutIfAvailable(
                    restTimerNotificationCoordinator.requestedWorkoutSessionID
                )
            }
            .onChange(of: restTimerNotificationCoordinator.requestedWorkoutSessionID) { _, request in
                presentRequestedWorkoutIfAvailable(request)
            }
            .onChange(of: activeWorkout?.id) { _, _ in
                presentRequestedWorkoutIfAvailable(
                    restTimerNotificationCoordinator.requestedWorkoutSessionID
                )
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else {
                    return
                }

                clearExpiredRestTimersIfNeeded()
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
        resumeActiveWorkout(returningHomeFirst: shouldReturnHomeFirst)
    }

    private func resumeActiveWorkout(for request: WorkoutStartRequest) {
        resumeActiveWorkout(returningHomeFirst: request.shouldReturnHomeFirst)
    }

    private func resumeActiveWorkout(returningHomeFirst shouldReturnHomeFirst: Bool) {
        pendingWorkoutStart = nil

        guard let activeWorkout else {
            return
        }

        presentWorkout(activeWorkout, returningHomeFirst: shouldReturnHomeFirst)
    }

    private func discardActiveWorkoutsAndStart(_ request: WorkoutStartRequest) {
        pendingWorkoutStart = nil
        let discardedWorkoutIDs = activeWorkoutSessions.map(\.id)

        do {
            try workoutService.discard(activeWorkoutSessions, in: modelContext)
            discardedWorkoutIDs.forEach { cancelRestTimerNotification(for: $0) }
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
            routineName: routine.name,
            hasActiveWorkout: activeWorkoutSessions.contains { workout in
                workout.sourceRoutineTemplateID == routine.id
            }
        )
    }

    private func requestDeleteWorkoutHistory(_ workout: WorkoutSession) {
        workoutHistoryDeletionRequest = WorkoutHistoryDeletionRequest(
            workoutID: workout.id,
            workoutName: workout.name
        )
    }

    private func deleteRequestedRoutine(_ request: RoutineDeletionRequest) {
        defer {
            self.routineDeletionRequest = nil
        }

        guard let routine = routines.first(where: { $0.id == request.routineID }) else {
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

    private func deleteRequestedWorkoutHistory(_ request: WorkoutHistoryDeletionRequest) {
        defer {
            self.workoutHistoryDeletionRequest = nil
        }

        guard let workout = completedWorkoutSessions.first(where: {
            $0.id == request.workoutID
        }) else {
            return
        }

        do {
            try workoutService.delete(workout, in: modelContext)
        } catch {
            homeError = HomeError(
                title: "Could Not Delete Workout",
                message: error.localizedDescription
            )
        }
    }

    private func presentRequestedWorkoutIfAvailable(_ requestedWorkoutSessionID: UUID?) {
        guard let requestedWorkoutSessionID else {
            return
        }

        guard activeWorkoutPresentation?.workoutSessionID != requestedWorkoutSessionID else {
            return
        }

        defer {
            restTimerNotificationCoordinator.consumeWorkoutPresentationRequest(
                requestedWorkoutSessionID
            )
        }

        guard let workout = activeWorkoutSessions.first(where: { $0.id == requestedWorkoutSessionID }) else {
            return
        }

        presentWorkout(workout, returningHomeFirst: true)
    }

    private func clearExpiredRestTimersIfNeeded() {
        for workout in activeWorkoutSessions {
            do {
                if try workoutService.clearExpiredRestTimer(for: workout, in: modelContext) {
                    cancelRestTimerNotification(for: workout.id)
                }
            } catch {
                homeError = HomeError(
                    title: "Could Not Save Rest Timer",
                    message: error.localizedDescription
                )
                return
            }
        }
    }

    private func cancelRestTimerNotification(for workoutID: UUID) {
        restTimerNotificationService.cancelRestTimerNotification(for: workoutID)
    }

}

private struct HomeConfirmationAlerts: ViewModifier {
    @Binding var pendingWorkoutStart: WorkoutStartRequest?
    @Binding var routineDeletionRequest: RoutineDeletionRequest?
    @Binding var workoutHistoryDeletionRequest: WorkoutHistoryDeletionRequest?

    let onResumeActiveWorkout: (WorkoutStartRequest) -> Void
    let onDiscardActiveWorkoutsAndStart: (WorkoutStartRequest) -> Void
    let onDeleteRoutine: (RoutineDeletionRequest) -> Void
    let onDeleteWorkoutHistory: (WorkoutHistoryDeletionRequest) -> Void

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

    private var isShowingWorkoutHistoryDeleteConfirmation: Binding<Bool> {
        Binding {
            workoutHistoryDeletionRequest != nil
        } set: { isPresented in
            if !isPresented {
                workoutHistoryDeletionRequest = nil
            }
        }
    }

    func body(content: Content) -> some View {
        content
            .alert(
                "Workout in Progress",
                isPresented: isShowingActiveWorkoutConflict,
                presenting: pendingWorkoutStart
            ) { request in
                Button("Resume Current Workout") {
                    onResumeActiveWorkout(request)
                }

                Button("Discard Current and Start New", role: .destructive) {
                    onDiscardActiveWorkoutsAndStart(request)
                }

                Button("Cancel", role: .cancel) {}
            } message: { _ in
                Text("You already have an active workout.")
            }
            .alert(
                routineDeletionRequest?.confirmationTitle ?? "Delete Routine?",
                isPresented: isShowingRoutineDeleteConfirmation,
                presenting: routineDeletionRequest
            ) { request in
                Button("Delete Routine", role: .destructive) {
                    onDeleteRoutine(request)
                }

                Button("Cancel", role: .cancel) {}
            } message: { request in
                Text(request.confirmationMessage)
            }
            .alert(
                "Delete Workout?",
                isPresented: isShowingWorkoutHistoryDeleteConfirmation,
                presenting: workoutHistoryDeletionRequest
            ) { request in
                Button("Delete Workout", role: .destructive) {
                    onDeleteWorkoutHistory(request)
                }

                Button("Cancel", role: .cancel) {}
            } message: { request in
                Text(request.confirmationMessage)
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
