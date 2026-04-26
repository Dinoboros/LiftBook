//
//  ActiveWorkoutSetRow.swift
//  LiftBook
//
//  Created by Codex on 26/04/2026.
//

import SwiftData
import SwiftUI

struct ActiveWorkoutSetRow: View {
    @Environment(\.modelContext) private var modelContext

    let setNumber: Int
    let set: WorkoutSet
    let canDelete: Bool
    let onDelete: () -> Void

    @FocusState private var focusedField: WorkoutSetField?
    @State private var repsText: String
    @State private var weightText: String

    init(
        setNumber: Int,
        set: WorkoutSet,
        canDelete: Bool,
        onDelete: @escaping () -> Void
    ) {
        self.setNumber = setNumber
        self.set = set
        self.canDelete = canDelete
        self.onDelete = onDelete
        _repsText = State(initialValue: Self.text(for: set.reps))
        _weightText = State(initialValue: Self.text(for: set.weight))
    }

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

            TextField("-", text: $repsText)
                .focused($focusedField, equals: .reps)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            TextField("-", text: $weightText)
                .focused($focusedField, equals: .weight)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Button(action: toggleCompleted) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(set.isCompleted ? .green : .secondary)
                    .frame(width: 44, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(set.isCompleted ? "Set logged" : "Set not logged")

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.body.weight(.semibold))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .opacity(canDelete ? 1 : 0)
            .disabled(!canDelete)
            .accessibilityLabel("Delete set \(setNumber)")
        }
        .font(.body)
        .padding(.vertical, 4)
        .background {
            Color(.secondarySystemGroupedBackground)
            rowGradient
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
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

    private func toggleCompleted() {
        set.isCompleted.toggle()
        saveSet()
    }

    private func commitDraft(for field: WorkoutSetField) {
        let didChange: Bool

        switch field {
        case .reps:
            didChange = applyRepsDraft()
        case .weight:
            didChange = applyWeightDraft()
        }

        if didChange {
            saveSet()
        }
    }

    private func commitDrafts() {
        let didChangeReps = applyRepsDraft()
        let didChangeWeight = applyWeightDraft()

        if didChangeReps || didChangeWeight {
            saveSet()
        }
    }

    private func applyRepsDraft() -> Bool {
        let newValue = Self.repsValue(from: repsText)
        let didChange = set.reps != newValue

        if didChange {
            set.reps = newValue
        }

        repsText = Self.text(for: set.reps)
        return didChange
    }

    private func applyWeightDraft() -> Bool {
        let newValue = Self.weightValue(from: weightText)
        let didChange = set.weight != newValue

        if didChange {
            set.weight = newValue
        }

        weightText = Self.text(for: set.weight)
        return didChange
    }

    private func saveSet() {
        try? modelContext.save()
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

private enum WorkoutSetField: Hashable {
    case reps
    case weight
}
