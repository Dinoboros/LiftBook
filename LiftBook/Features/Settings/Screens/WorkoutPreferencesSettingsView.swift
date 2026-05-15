//
//  WorkoutPreferencesSettingsView.swift
//  LiftBook
//
//  Created by Codex on 15/05/2026.
//

import SwiftUI

struct WorkoutPreferencesSettingsView: View {
    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue
    @AppStorage(LBSettingsKeys.defaultRestTimerDurationSeconds) private var defaultRestTimerDurationSeconds = RestTimerDuration.defaultValue.rawValue

    private var preferredWeightUnit: Binding<WeightUnit> {
        Binding {
            WeightUnit(rawValue: preferredWeightUnitRawValue) ?? .kilograms
        } set: { unit in
            preferredWeightUnitRawValue = unit.rawValue
        }
    }

    private var defaultRestTimerDuration: Binding<RestTimerDuration> {
        Binding {
            RestTimerDuration(seconds: defaultRestTimerDurationSeconds)
        } set: { duration in
            defaultRestTimerDurationSeconds = duration.rawValue
        }
    }

    var body: some View {
        List {
            Section("Units") {
                Picker("Weight Unit", selection: preferredWeightUnit) {
                    ForEach(WeightUnit.allCases) { unit in
                        Text(unit.rawValue)
                            .tag(unit)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Picker("Default Rest Timer", selection: defaultRestTimerDuration) {
                    ForEach(RestTimerDuration.allCases) { duration in
                        Text(duration.title)
                            .tag(duration)
                    }
                }
            } header: {
                Text("Rest Timer")
            } footer: {
                Text("New rest timers start with this duration. Active timers keep their current deadline.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(LBColor.background)
        .navigationTitle("Workout Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorkoutPreferencesSettingsView()
    }
}
