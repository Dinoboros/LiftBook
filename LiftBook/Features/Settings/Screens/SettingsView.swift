//
//  SettingsView.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue
    @AppStorage(LBSettingsKeys.restTimerNotificationsEnabled) private var restTimerNotificationsEnabled = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.restTimerNotificationService) private var restTimerNotificationService

    @State private var isShowingOnboardingConfirmation = false
    @State private var isShowingNotificationSettingsAlert = false
    @State private var isShowingDebug = false

    private var preferredWeightUnit: Binding<WeightUnit> {
        Binding {
            WeightUnit(rawValue: preferredWeightUnitRawValue) ?? .kilograms
        } set: { unit in
            preferredWeightUnitRawValue = unit.rawValue
        }
    }

    var body: some View {
        List {
            Section("Preferences") {
                Picker("Weight Unit", selection: preferredWeightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.rawValue)
                            .tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Toggle("Rest Timer Notifications", isOn: restTimerNotificationsPreference)
                    .accessibilityIdentifier("restTimerNotificationsSettingsToggle")
            } header: {
                Text("Notifications")
            } footer: {
                Text("Turn this off to stop rest timer alerts and cancel pending rest notifications.")
            }

            Section("Library") {
                NavigationLink {
                    ExerciseLibraryView()
                } label: {
                    Label("Exercise Library", systemImage: "figure.strengthtraining.traditional")
                }
                .accessibilityIdentifier("exerciseLibrarySettingsRow")
            }

            Section("Developer") {
                Button {
                    isShowingDebug = true
                } label: {
                    Label("Debug", systemImage: "ladybug")
                }
                .accessibilityIdentifier("debugSettingsRow")
            }

            Section {
                Button {
                    isShowingOnboardingConfirmation = true
                } label: {
                    Label("Show Onboarding Again", systemImage: "sparkles")
                }
            } header: {
                Text("Setup")
            } footer: {
                Text("Your workouts, routines, and exercises will stay saved.")
            }

            Section("About") {
                LabeledContent("App", value: appName)
                LabeledContent("Version", value: version)
                LabeledContent("Build", value: build)
                LabeledContent("Bundle", value: bundleIdentifier)
            }
        }
        .scrollContentBackground(.hidden)
        .background(LBColor.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Show Onboarding Again?",
            isPresented: $isShowingOnboardingConfirmation,
            titleVisibility: .visible
        ) {
            Button("Show Onboarding Again") {
                hasCompletedOnboarding = false
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The onboarding flow will appear again. Your data will not be deleted.")
        }
        .sheet(isPresented: $isShowingDebug) {
            NavigationStack {
                AppDebugView()
            }
        }
        .alert("Notifications Disabled", isPresented: $isShowingNotificationSettingsAlert) {
            Button("Open Settings", action: openSystemSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Allow notifications for LiftBook in iOS Settings to turn this on.")
        }
        .task {
            await reconcileRestTimerNotificationsPreference()
        }
    }

    private var restTimerNotificationsPreference: Binding<Bool> {
        Binding {
            restTimerNotificationsEnabled
        } set: { isEnabled in
            updateRestTimerNotificationsPreference(isEnabled)
        }
    }

    private var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "LiftBook"
    }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "1.0"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            ?? "1"
    }

    private var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "Unavailable"
    }

    private func updateRestTimerNotificationsPreference(_ isEnabled: Bool) {
        guard isEnabled else {
            restTimerNotificationsEnabled = false
            Task {
                await restTimerNotificationService.cancelAllRestTimerNotifications()
            }
            return
        }

        Task {
            let canEnable = await restTimerNotificationService.canEnableFromSettings()

            await MainActor.run {
                restTimerNotificationsEnabled = canEnable
                isShowingNotificationSettingsAlert = !canEnable
            }
        }
    }

    private func reconcileRestTimerNotificationsPreference() async {
        let isEnabled = await restTimerNotificationService
            .reconcilePreferenceWithSystemAuthorization()

        await MainActor.run {
            restTimerNotificationsEnabled = isEnabled
        }
    }

    private func openSystemSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        UIApplication.shared.open(settingsURL)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
