//
//  OnboardingView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]

    let onComplete: () -> Void

    @State private var setupState: OnboardingSetupState = .idle

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 36)

                    VStack(spacing: 24) {
                        appMark

                        VStack(spacing: 10) {
                            Text("LiftBook")
                                .font(.largeTitle.bold())

                            Text("Build routines, log workouts, and keep your training history organized.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        OnboardingFeatureRow(
                            systemImage: "list.bullet.rectangle",
                            title: "Plan routines",
                            detail: "Save repeatable workouts with the exercises you use most."
                        )

                        OnboardingFeatureRow(
                            systemImage: "figure.strengthtraining.traditional",
                            title: "Exercise library",
                            detail: "A ready-to-use exercise list is added locally during setup."
                        )

                        OnboardingFeatureRow(
                            systemImage: "chart.line.uptrend.xyaxis",
                            title: "Track sessions",
                            detail: "Start empty workouts or train from a saved routine."
                        )
                    }
                    .padding(.top, 44)

                    Spacer(minLength: 32)
                }
            }
            .scrollIndicators(.hidden)

            setupStatusView
                .padding(.bottom, 18)

            Button(action: onComplete) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!setupState.isReady)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .task {
            await prepareExerciseLibrary()
        }
    }

    private var appMark: some View {
        ZStack {
            Circle()
                .fill(.tint.opacity(0.14))
                .frame(width: 88, height: 88)

            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(.tint)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var setupStatusView: some View {
        switch setupState {
        case .idle:
            Label("Preparing exercise library", systemImage: "clock")
                .font(.footnote)
                .foregroundStyle(.secondary)

        case .preparing(let imported, let total):
            VStack(spacing: 10) {
                if total > 0 {
                    ProgressView(value: Double(imported), total: Double(total))
                        .frame(maxWidth: 260)

                    Text("Importing \(imported) of \(total) exercises")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView("Preparing exercise library")
                        .font(.footnote)
                }
            }
            .frame(maxWidth: .infinity)

        case .ready(let count):
            Label("\(count) exercises ready", systemImage: "checkmark.circle.fill")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.green)

        case .failed(let message):
            VStack(spacing: 12) {
                Label("Setup failed", systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.orange)

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    Task {
                        await prepareExerciseLibrary()
                    }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @MainActor
    private func prepareExerciseLibrary() async {
        guard !setupState.isPreparing, !setupState.isReady else {
            return
        }

        setupState = .preparing(imported: 0, total: 0)

        do {
            let result = try await ExerciseLibrarySeeder().prepareLibrary(
                into: modelContext,
                existingExercises: exercises
            ) { progress in
                setupState = .preparing(imported: progress.imported, total: progress.total)
            }

            setupState = .ready(count: result.count)
        } catch is CancellationError {
            return
        } catch {
            setupState = .failed(error.localizedDescription)
        }
    }
}

private struct OnboardingFeatureRow: View {
    let systemImage: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(.tint)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.headline)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private enum OnboardingSetupState: Equatable {
    case idle
    case preparing(imported: Int, total: Int)
    case ready(count: Int)
    case failed(String)

    var isPreparing: Bool {
        if case .preparing = self {
            return true
        }
        return false
    }

    var isReady: Bool {
        if case .ready = self {
            return true
        }
        return false
    }
}

#Preview {
    OnboardingView {}
        .modelContainer(
            for: [
                Exercise.self,
                RoutineTemplate.self,
                RoutineTemplateExercise.self,
                WorkoutSession.self,
                WorkoutSessionExercise.self,
                WorkoutSet.self,
            ],
            inMemory: true
        )
}
