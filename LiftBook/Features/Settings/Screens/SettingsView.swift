//
//  SettingsView.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SettingsHubGroup {
                    SettingsNavigationRow(
                        title: "Workout Preferences",
                        summary: "Weight unit, default rest timer",
                        systemImage: "figure.strengthtraining.traditional",
                        accessibilityIdentifier: "workoutPreferencesSettingsRow"
                    ) {
                        WorkoutPreferencesSettingsView()
                    }

                    SettingsHubDivider()

                    SettingsNavigationRow(
                        title: "Notifications",
                        summary: "Rest timer alerts, permissions",
                        systemImage: "bell",
                        accessibilityIdentifier: "notificationsSettingsRow"
                    ) {
                        NotificationSettingsView()
                    }
                }

                SettingsHubGroup {
                    SettingsNavigationRow(
                        title: "Exercise Library",
                        summary: "Exercises, custom movements, categories",
                        systemImage: "list.bullet.rectangle",
                        accessibilityIdentifier: "exerciseLibrarySettingsRow"
                    ) {
                        ExerciseLibraryView()
                    }
                }

                SettingsHubGroup {
                    #if DEBUG
                        SettingsNavigationRow(
                            title: "Developer",
                            summary: "Debug tools",
                            systemImage: "hammer",
                            accessibilityIdentifier: "debugSettingsRow"
                        ) {
                            AppDebugView()
                        }

                        SettingsHubDivider()
                    #endif

                    SettingsNavigationRow(
                        title: "About",
                        summary: "Version, build, bundle ID",
                        systemImage: "info.circle",
                        accessibilityIdentifier: "aboutSettingsRow"
                    ) {
                        AboutSettingsView()
                    }
                }
            }
            .padding(.horizontal, LBCardLayout.scrollHorizontalPadding)
            .padding(.vertical, 20)
        }
        .background(LBColor.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SettingsHubGroup<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .lbCardSurface()
    }
}

private struct SettingsNavigationRow<Destination: View>: View {
    let title: String
    let summary: String
    let systemImage: String
    let accessibilityIdentifier: String
    let destination: () -> Destination

    init(
        title: String,
        summary: String,
        systemImage: String,
        accessibilityIdentifier: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self.title = title
        self.summary = summary
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.destination = destination
    }

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            SettingsHubRow(
                title: title,
                summary: summary,
                systemImage: systemImage
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

private struct SettingsHubRow: View {
    let title: String
    let summary: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 14) {
            iconWell

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)

                Text(summary)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 74, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var iconWell: some View {
        RoundedRectangle(cornerRadius: LBRadius.chip, style: .continuous)
            .fill(LBColor.workoutStart.opacity(0.12))
            .frame(width: 38, height: 38)
            .overlay {
                Image(systemName: systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(LBColor.workoutStart)
            }
    }
}

private struct SettingsHubDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 68)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
