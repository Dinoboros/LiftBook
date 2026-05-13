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
    let weightUnit: WeightUnit
    let canDelete: Bool
    let onDelete: () -> Void
    let onUpdate: (Int?, Double?) -> Void
    let onToggleCompleted: () -> Void

    @FocusState private var focusedField: WorkoutSetField?
    @State private var repsText: String
    @State private var weightText: String
    @State private var committedWeightText: String

    init(
        setNumber: Int,
        set: WorkoutSet,
        weightUnit: WeightUnit = .kilograms,
        canDelete: Bool,
        onDelete: @escaping () -> Void,
        onUpdate: @escaping (Int?, Double?) -> Void,
        onToggleCompleted: @escaping () -> Void
    ) {
        self.setNumber = setNumber
        self.set = set
        self.weightUnit = weightUnit
        self.canDelete = canDelete
        self.onDelete = onDelete
        self.onUpdate = onUpdate
        self.onToggleCompleted = onToggleCompleted
        _repsText = State(initialValue: Self.text(for: set.reps))
        let weightText = LBWeightFormatter.editableText(
            forKilograms: set.weight,
            unit: weightUnit
        )
        _weightText = State(initialValue: weightText)
        _committedWeightText = State(initialValue: weightText)
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
                    .focusedValue(\.lbKeyboardDismissAction) {
                        focusedField = nil
                    }
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)

                LBExerciseSetColumnDivider()

                TextField("-", text: $weightText)
                    .focused($focusedField, equals: .weight)
                    .focusedValue(\.lbKeyboardDismissAction) {
                        focusedField = nil
                    }
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.plain)
                    .frame(maxWidth: .infinity)

                LBExerciseSetColumnDivider()

                Button(action: toggleCompleted) {
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

            updateCommittedWeightText(forKilograms: newValue)
        }
        .onChange(of: weightUnit) {
            guard focusedField != .weight else {
                return
            }

            updateCommittedWeightText(forKilograms: set.weight)
        }
        .onDisappear(perform: commitDrafts)
    }

    private func toggleCompleted() {
        commitDrafts()
        focusedField = nil
        onToggleCompleted()
    }

    private func commitDraft(for field: WorkoutSetField) {
        switch field {
        case .reps:
            commitRepsDraft()
        case .weight:
            commitWeightDraft()
        }
    }

    private func commitDrafts() {
        let reps = Self.repsValue(from: repsText)
        let didEditWeight = weightText != committedWeightText
        let weight = didEditWeight
            ? LBWeightFormatter.kilograms(fromDisplayText: weightText, unit: weightUnit)
            : set.weight
        let didChangeReps = set.reps != reps
        let didChangeWeight = didEditWeight && !Self.weightsEqual(set.weight, weight)

        if didChangeReps || didChangeWeight {
            onUpdate(reps, weight)
        }

        repsText = Self.text(for: reps)
        updateCommittedWeightText(forKilograms: weight)
    }

    private func commitRepsDraft() {
        let reps = Self.repsValue(from: repsText)

        if set.reps != reps {
            onUpdate(reps, set.weight)
        }

        repsText = Self.text(for: reps)
    }

    private func commitWeightDraft() {
        guard weightText != committedWeightText else {
            weightText = committedWeightText
            return
        }

        let weight = LBWeightFormatter.kilograms(fromDisplayText: weightText, unit: weightUnit)

        if !Self.weightsEqual(set.weight, weight) {
            onUpdate(set.reps, weight)
        }

        updateCommittedWeightText(forKilograms: weight)
    }

    private func updateCommittedWeightText(forKilograms weight: Double?) {
        let text = LBWeightFormatter.editableText(forKilograms: weight, unit: weightUnit)
        weightText = text
        committedWeightText = text
    }

    private static func repsValue(from text: String) -> Int? {
        let trimmedValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : Int(trimmedValue)
    }

    private static func text(for reps: Int?) -> String {
        guard let reps else {
            return ""
        }

        return String(reps)
    }

    private static func weightsEqual(_ lhs: Double?, _ rhs: Double?) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil):
            return true
        case let (lhs?, rhs?):
            return abs(lhs - rhs) < 0.000_001
        default:
            return false
        }
    }
}
