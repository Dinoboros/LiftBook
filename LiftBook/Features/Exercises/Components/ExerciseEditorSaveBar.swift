//
//  ExerciseEditorSaveBar.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct ExerciseEditorSaveBar: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "plus.circle.fill")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background {
                    Capsule()
                        .fill(LBColor.workoutStart)
                }
                .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
        .accessibilityIdentifier("customExerciseSaveButton")
        .padding(.horizontal, LBCardLayout.scrollHorizontalPadding)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}
