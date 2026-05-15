//
//  NotificationSettingsView.swift
//  LiftBook
//
//  Created by Codex on 15/05/2026.
//

import SwiftUI
import UIKit

struct NotificationSettingsView: View {
    @AppStorage(LBSettingsKeys.restTimerNotificationsEnabled) private var restTimerNotificationsEnabled = false
    @Environment(\.restTimerNotificationService) private var restTimerNotificationService

    @State private var isRequestingNotificationAuthorization = false
    @State private var isShowingNotificationSettingsAlert = false

    var body: some View {
        List {
            Section {
                Toggle("Rest Timer Alerts", isOn: restTimerNotificationsPreference)
                    .disabled(isRequestingNotificationAuthorization)
                    .accessibilityIdentifier("restTimerNotificationsSettingsToggle")
            } header: {
                Text("Rest Timer")
            } footer: {
                Text("Turn this on to get alerted when a rest timer ends.")
            }

            Section {
                Button {
                    openSystemSettings()
                } label: {
                    Label("Open iOS Settings", systemImage: "gearshape")
                }
            } footer: {
                Text("Use iOS Settings if notifications are disabled at the system level.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(LBColor.background)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
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

    private func updateRestTimerNotificationsPreference(_ isEnabled: Bool) {
        guard isEnabled else {
            restTimerNotificationsEnabled = false
            Task {
                await restTimerNotificationService.cancelAllRestTimerNotifications()
            }
            return
        }

        Task {
            await MainActor.run {
                isRequestingNotificationAuthorization = true
            }

            let canEnable = await restTimerNotificationService
                .requestAuthorizationFromUserAction()

            await MainActor.run {
                restTimerNotificationsEnabled = canEnable
                isRequestingNotificationAuthorization = false
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
        NotificationSettingsView()
    }
}
