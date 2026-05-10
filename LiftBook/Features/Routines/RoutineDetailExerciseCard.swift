//
//  RoutineDetailExerciseCard.swift
//  LiftBook
//
//  Created by Méryl VALIER on 24/04/2026.
//

import SwiftUI

struct RoutineDetailExerciseCard: View {
    let exercise: RoutineTemplateExercise

    private var setNumbers: [Int] {
        Array(1...exercise.targetSetCount)
    }

    private var targetSets: [RoutineTemplateSet] {
        exercise.sortedSets
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(exercise.exerciseName)
                .font(.title3.weight(.semibold))

            VStack(spacing: 10) {
                HStack(spacing: 12) {
                    Text("Set #")
                        .frame(maxWidth: .infinity)
                    Text("Reps")
                        .frame(maxWidth: .infinity)
                    Text("Weight")
                        .frame(maxWidth: .infinity)
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

                ForEach(setNumbers, id: \.self) { setNumber in
                    RoutineDetailSetRow(
                        setNumber: setNumber,
                        set: targetSets[safe: setNumber - 1]
                    )
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
    }
}

private struct RoutineDetailSetRow: View {
    let setNumber: Int
    let set: RoutineTemplateSet?

    private var rowGradientColors: [Color] {
        if setNumber.isMultiple(of: 2) {
            return [
                .teal.opacity(0.14),
                .cyan.opacity(0.07)
            ]
        }

        return [
            .indigo.opacity(0.13),
            .blue.opacity(0.06)
        ]
    }

    private var rowGradient: LinearGradient {
        LinearGradient(
            colors: rowGradientColors,
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(setNumber)")
                .frame(maxWidth: .infinity)

            Text(repsText)
                .frame(maxWidth: .infinity)

            Text(weightText)
                .frame(maxWidth: .infinity)
        }
        .font(.body)
        .padding(.vertical, 4)
        .background {
            Color(.secondarySystemGroupedBackground)
            rowGradient
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var repsText: String {
        guard let reps = set?.reps else {
            return "-"
        }

        return String(reps)
    }

    private var weightText: String {
        guard let weight = set?.weight else {
            return "-"
        }

        if weight.rounded() == weight {
            return String(Int(weight))
        }

        return String(weight)
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
