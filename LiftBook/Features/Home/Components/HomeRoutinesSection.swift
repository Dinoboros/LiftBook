//
//  HomeRoutinesSection.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct HomeRoutinesSection: View {
    let routines: [RoutineTemplate]
    let rowInsets: EdgeInsets
    let onOpen: (RoutineTemplate) -> Void
    let onStart: (RoutineTemplate) -> Void
    let onEdit: (RoutineTemplate) -> Void
    let onDelete: (RoutineTemplate) -> Void

    var body: some View {
        Section("Routines") {
            if routines.isEmpty {
                LBSectionEmptyStateCard(
                    systemImage: "calendar",
                    title: "No routines yet",
                    message: "Create your first reusable plan."
                )
                .listRowInsets(rowInsets)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(routines) { routine in
                    RoutineCard(
                        title: routine.name,
                        exerciseSummary: HomeWorkoutFormatter.exerciseSummary(for: routine),
                        onOpen: { onOpen(routine) },
                        onStart: { onStart(routine) },
                        onEdit: { onEdit(routine) },
                        onDelete: { onDelete(routine) }
                    )
                    .listRowInsets(rowInsets)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
        }
    }
}
