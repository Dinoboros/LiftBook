//
//  SettingsView.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var isShowingOnboardingConfirmation = false

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
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
