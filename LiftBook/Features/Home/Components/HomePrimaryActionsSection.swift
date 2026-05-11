//
//  HomePrimaryActionsSection.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct HomePrimaryActionsSection: View {
    let rowInsets: EdgeInsets
    let onStartEmptyWorkout: () -> Void
    let onCreateRoutine: () -> Void

    var body: some View {
        Section {
            LBSplitActionControl(
                leadingAction: LBSplitAction(
                    title: "Start Empty Workout",
                    systemImage: "plus.circle.fill",
                    action: onStartEmptyWorkout
                ),
                trailingAction: LBSplitAction(
                    title: "Create Routine",
                    systemImage: "doc.badge.plus",
                    action: onCreateRoutine
                )
            )
            .listRowInsets(rowInsets)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }
}
