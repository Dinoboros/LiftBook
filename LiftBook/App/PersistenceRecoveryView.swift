//
//  PersistenceRecoveryView.swift
//  LiftBook
//
//  Created by Codex on 16/05/2026.
//

import SwiftUI

struct PersistenceRecoveryView: View {
    let error: Error
    let onRetry: () -> Void
    let onReset: () -> Void

    @State private var isShowingResetConfirmation = false

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 14) {
                Image(systemName: "externaldrive.badge.exclamationmark")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(LBColor.warning)
                    .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("LiftBook could not open your local data")
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)

                    Text("Try again. If the problem continues, reset local data to create a fresh database.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(spacing: 12) {
                Button("Try Again", action: onRetry)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                Button("Reset Local Data", role: .destructive) {
                    isShowingResetConfirmation = true
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            Text(error.localizedDescription)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: 420)
        .lbCardSurface()
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LBColor.background.ignoresSafeArea())
        .alert("Reset Local Data?", isPresented: $isShowingResetConfirmation) {
            Button("Reset Local Data", role: .destructive, action: onReset)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This deletes routines, workouts, workout history, and custom exercises stored on this device. This cannot be undone.")
        }
    }
}

#Preview {
    PersistenceRecoveryView(
        error: CocoaError(.fileReadCorruptFile),
        onRetry: {},
        onReset: {}
    )
}
