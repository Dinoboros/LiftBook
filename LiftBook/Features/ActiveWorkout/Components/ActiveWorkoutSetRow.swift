//
//  ActiveWorkoutSetRow.swift
//  LiftBook
//
//  Created by Codex on 26/04/2026.
//

import SwiftUI

struct ActiveWorkoutSetRow: View {
    let setNumber: Int
    let set: WorkoutSet
    let canDelete: Bool
    let onDelete: () -> Void
    let onUpdate: (Int?, Double?) -> Void
    let onToggleCompleted: () -> Void

    @FocusState private var focusedField: WorkoutSetField?
    @State private var repsText: String
    @State private var weightText: String

    init(
        setNumber: Int,
        set: WorkoutSet,
        canDelete: Bool,
        onDelete: @escaping () -> Void,
        onUpdate: @escaping (Int?, Double?) -> Void,
        onToggleCompleted: @escaping () -> Void
    ) {
        self.setNumber = setNumber
        self.set = set
        self.canDelete = canDelete
        self.onDelete = onDelete
        self.onUpdate = onUpdate
        self.onToggleCompleted = onToggleCompleted
        _repsText = State(initialValue: Self.text(for: set.reps))
        _weightText = State(initialValue: Self.text(for: set.weight))
    }

    var body: some View {
        LBSwipeDeleteSetRow(
            canDelete: canDelete,
            deleteAccessibilityLabel: "Delete set \(setNumber)",
            onDelete: onDelete
        ) {
            HStack(spacing: 0) {
                Text("\(setNumber)")
                    .frame(width: LBExerciseCardMetrics.setNumberWidth)

                LBExerciseSetColumnDivider()

                TextField("-", text: $repsText)
                    .focused($focusedField, equals: .reps)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)

                LBExerciseSetColumnDivider()

                TextField("-", text: $weightText)
                    .focused($focusedField, equals: .weight)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)

                LBExerciseSetColumnDivider()

                Button(action: onToggleCompleted) {
                    Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(set.isCompleted ? LBColor.workoutStart : Color.secondary)
                        .frame(
                            width: LBExerciseCardMetrics.completionWidth,
                            height: LBExerciseCardMetrics.rowHeight
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(set.isCompleted ? "Set logged" : "Set not logged")
            }
            .frame(maxWidth: .infinity, minHeight: LBExerciseCardMetrics.rowHeight)
            .background {
                LBExerciseSetRowBackground(isCompleted: set.isCompleted)
            }
        }
        .font(.body)
        .onChange(of: focusedField) { oldField, newField in
            guard let oldField, oldField != newField else {
                return
            }

            commitDraft(for: oldField)
        }
        .onChange(of: set.reps) { _, newValue in
            guard focusedField != .reps else {
                return
            }

            repsText = Self.text(for: newValue)
        }
        .onChange(of: set.weight) { _, newValue in
            guard focusedField != .weight else {
                return
            }

            weightText = Self.text(for: newValue)
        }
        .onDisappear(perform: commitDrafts)
    }

    private func commitDraft(for field: WorkoutSetField) {
        let reps = Self.repsValue(from: repsText)
        let weight = Self.weightValue(from: weightText)

        let didChange: Bool
        switch field {
        case .reps:
            didChange = set.reps != reps
        case .weight:
            didChange = set.weight != weight
        }

        if didChange {
            onUpdate(reps, weight)
        }

        repsText = Self.text(for: reps)
        weightText = Self.text(for: weight)
    }

    private func commitDrafts() {
        let reps = Self.repsValue(from: repsText)
        let weight = Self.weightValue(from: weightText)
        let didChangeReps = set.reps != reps
        let didChangeWeight = set.weight != weight

        if didChangeReps || didChangeWeight {
            onUpdate(reps, weight)
        }

        repsText = Self.text(for: reps)
        weightText = Self.text(for: weight)
    }

    private static func repsValue(from text: String) -> Int? {
        let trimmedValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : Int(trimmedValue)
    }

    private static func weightValue(from text: String) -> Double? {
        let trimmedValue = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !trimmedValue.isEmpty, let weight = Double(trimmedValue), weight.isFinite else {
            return nil
        }

        return weight
    }

    private static func text(for reps: Int?) -> String {
        guard let reps else {
            return ""
        }

        return String(reps)
    }

    private static func text(for weight: Double?) -> String {
        guard let weight else {
            return ""
        }

        if weight.rounded() == weight {
            return String(Int(weight))
        }

        return String(weight)
    }
}
