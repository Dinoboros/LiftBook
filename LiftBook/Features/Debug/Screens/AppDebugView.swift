//
//  AppDebugView.swift
//  LiftBook
//
//  Created by Codex on 10/05/2026.
//

#if DEBUG
import SwiftData
import SwiftUI

struct AppDebugView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext

    @State private var pendingAction: AppDebugAction?
    @State private var isRunningAction = false
    @State private var resetError: AppDebugResetError?
    @State private var statusMessage: String?

    var body: some View {
        List {
            Section("Seed Data") {
                NavigationLink {
                    ExerciseSeedDebugView()
                } label: {
                    DebugNavigationRow(
                        title: "Default Exercises",
                        subtitle: "Inspect the bundled exercise seed",
                        systemImage: "list.bullet.rectangle"
                    )
                }

                Button {
                    pendingAction = .reloadExerciseLibrary
                } label: {
                    Label("Reload Exercise Library", systemImage: "arrow.clockwise")
                }
                .disabled(isRunningAction)
            }

            Section {
                Button(role: .destructive) {
                    pendingAction = .clearWorkoutData
                } label: {
                    Label("Clear Workouts and Routines", systemImage: "trash")
                }
                .disabled(isRunningAction)

                Button(role: .destructive) {
                    pendingAction = .freshInstallReset
                } label: {
                    Label("Start Over Like Fresh Install", systemImage: "arrow.counterclockwise")
                }
                .disabled(isRunningAction)
            } header: {
                Text("Reset")
            } footer: {
                Text("Fresh install reset deletes workouts, routines, exercises, and custom exercises, then shows onboarding again.")
            }

            if isRunningAction || statusMessage != nil {
                Section("Status") {
                    if isRunningAction {
                        HStack {
                            ProgressView()
                            Text("Running debug action")
                        }
                    }

                    if let statusMessage {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(LBColor.background)
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            pendingAction?.title ?? "Confirm Debug Action",
            isPresented: isShowingPendingActionConfirmation,
            titleVisibility: .visible
        ) {
            if let pendingAction {
                Button(pendingAction.confirmationButtonTitle, role: pendingAction.buttonRole) {
                    Task {
                        await runPendingAction()
                    }
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(pendingAction?.confirmationMessage ?? "")
        }
        .alert(item: $resetError) { error in
            Alert(
                title: Text("Debug Action Failed"),
                message: Text(error.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var isShowingPendingActionConfirmation: Binding<Bool> {
        Binding {
            pendingAction != nil
        } set: { isPresented in
            if !isPresented {
                pendingAction = nil
            }
        }
    }

    @MainActor
    private func runPendingAction() async {
        guard let action = pendingAction, !isRunningAction else {
            return
        }

        pendingAction = nil
        isRunningAction = true
        statusMessage = nil

        defer {
            isRunningAction = false
        }

        do {
            switch action {
            case .reloadExerciseLibrary:
                try await reloadExerciseLibrary()
            case .clearWorkoutData:
                try clearWorkoutData()
                statusMessage = "Workouts and routines cleared."
            case .freshInstallReset:
                try clearAllAppData()
                hasCompletedOnboarding = false
                statusMessage = "App reset. Onboarding will show again."
            }
        } catch {
            resetError = AppDebugResetError(message: error.localizedDescription)
        }
    }

    @MainActor
    private func reloadExerciseLibrary() async throws {
        try deleteAll(Exercise.self)
        try modelContext.save()

        let result = try await ExerciseSeedImporter().importExercises(into: modelContext)
        statusMessage = "Reloaded \(result.importedCount) default exercises."
    }

    private func clearWorkoutData() throws {
        try deleteAll(WorkoutSession.self)
        try deleteAll(RoutineTemplate.self)
        try modelContext.save()
    }

    private func clearAllAppData() throws {
        try clearWorkoutData()
        try deleteAll(Exercise.self)
        try modelContext.save()
    }

    private func deleteAll<T: PersistentModel>(_ modelType: T.Type) throws {
        let descriptor = FetchDescriptor<T>()
        let models = try modelContext.fetch(descriptor)

        for model in models {
            modelContext.delete(model)
        }
    }
}

#Preview {
    NavigationStack {
        AppDebugView()
    }
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
#endif
