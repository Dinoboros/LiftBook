//
//  HomeView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: startEmptyWorkout) {
                        Label("Start Empty Workout", systemImage: "plus.circle.fill")
                    }

                    Button(action: createRoutine) {
                        Label("Create Routine", systemImage: "doc.badge.plus")
                    }
                }

                Section("Routines") {
                    ContentUnavailableView(
                        "No Routines",
                        systemImage: "list.bullet.rectangle",
                        description: Text("Saved routines will appear here.")
                    )
                }
            }
            .navigationTitle("Home")
        }
    }

    private func startEmptyWorkout() {
        // Active workout flow will be wired in the next slice.
    }

    private func createRoutine() {
        // Routine creation flow will be wired in the next slice.
    }
}

#Preview {
    HomeView()
}
