//
//  MuscleSelectionView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 21/10/2025.
//

import SwiftUI

struct MuscleSelectionView: View {
    @Binding var selectedMuscles: [MuscleGroup]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        let muscles: [MuscleGroup] = $selectedMuscles.wrappedValue
        return List {
            ForEach(MuscleGroup.allCases.sorted(by: { $0.displayName < $1.displayName })) { muscle in
                Button {
                    if let muscleIndex = muscles.firstIndex(of: muscle) {
                        $selectedMuscles.wrappedValue.remove(at: muscleIndex)
                    } else {
                        $selectedMuscles.wrappedValue.append(muscle)
                    }
                } label: {
                    HStack {
                        Text(muscle.displayName)
                        Spacer()
                        if muscles.contains(muscle) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.primary)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.plain)
            }
        }
    }
}
