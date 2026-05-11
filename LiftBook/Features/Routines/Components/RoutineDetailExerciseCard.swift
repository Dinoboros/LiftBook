//
//  RoutineDetailExerciseCard.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI

struct RoutineDetailExerciseCard: View {
    let exercise: RoutineTemplateExercise
    let subtitle: String?

    private var setNumbers: [Int] {
        Array(1...exercise.targetSetCount)
    }

    private var targetSets: [RoutineTemplateSet] {
        exercise.sortedSets
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.exerciseName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 8) {
                LBExerciseSetTableHeader(showsCompletionColumn: false)

                ForEach(setNumbers, id: \.self) { setNumber in
                    RoutineDetailSetRow(
                        setNumber: setNumber,
                        set: targetSet(at: setNumber - 1)
                    )
                }
            }
        }
        .lbExpandedExerciseCardSurface()
    }

    private func targetSet(at index: Int) -> RoutineTemplateSet? {
        guard targetSets.indices.contains(index) else {
            return nil
        }

        return targetSets[index]
    }
}
