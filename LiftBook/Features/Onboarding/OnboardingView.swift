//
//  OnboardingView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 11/10/2025.
//

import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isFirstLaunch") private var isFirstLaunch = false
    @AppStorage("isLoadingExercises") private var isLoadingExercises = false
    
    
    @State private var progress: Double = 0
    @State private var status: String = "Preparation…"
    @State private var error: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Preparing your exercises library…")
            ProgressView(value: progress, total: 1)
                .progressViewStyle(.linear)
            Text(status)
                .font(.body)
                .foregroundStyle(.secondary)
            if let error = error {
                Text("Error: \(error)")
                    .font(.body)
                    .foregroundStyle(.red)
                Button("Retry") {
                    Task {
                        await loadExercises()
                    }
                }
            }
        }
        .padding()
        .task {
            await loadExercises()
        }
    }
    
    private func loadExercises() async {
        isLoadingExercises = true
        defer { isLoadingExercises = false }
        do {
            let store = ExerciseStore(modelContext: modelContext)
            try await store.loadExercisesFromJSON { progress, status in
                self.progress = progress
                self.status = status
            }
            isFirstLaunch = true
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.status = "Loading failed"
            }
        }
    }
}

#Preview {
    OnboardingView()
}
