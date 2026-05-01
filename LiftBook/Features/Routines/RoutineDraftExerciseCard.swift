//
//  RoutineDraftExerciseCard.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import SwiftUI

struct RoutineDraftExerciseCard: View {
    @Binding var exercise: RoutineExerciseDraft
    let showsSubtitle: Bool
    let showsSetInputs: Bool
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.exerciseName)
                        .font(.title3.weight(.semibold))

                    if showsSubtitle, !exercise.subtitle.isEmpty {
                        Text(exercise.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Menu {
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete Exercise", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Exercise options")
            }

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

                ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                    RoutineDraftSetRow(
                        setNumber: index + 1,
                        set: $exercise.sets[index],
                        canDelete: exercise.sets.count > 1,
                        showsInputs: showsSetInputs,
                        onDelete: { deleteSet(id: set.id) }
                    )
                }
            }

            Button(action: addSet) {
                Label("Add set", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
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

    private func addSet() {
        exercise.sets.append(RoutineSetDraft())
    }

    private func deleteSet(id: UUID) {
        guard exercise.sets.count > 1 else {
            return
        }

        exercise.sets.removeAll { $0.id == id }
    }
}

private struct RoutineDraftSetRow: View {
    let setNumber: Int
    @Binding var set: RoutineSetDraft
    let canDelete: Bool
    let showsInputs: Bool
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0

    private let deleteButtonWidth: CGFloat = 72
    private let revealThreshold: CGFloat = 24

    private var isDeleteRevealed: Bool {
        offset < 0
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
        ZStack(alignment: .trailing) {
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: deleteButtonWidth)
                    .frame(maxHeight: .infinity)
                    .background(.red)
            }
            .buttonStyle(.plain)
            .opacity(canDelete && isDeleteRevealed ? 1 : 0)
            .accessibilityLabel("Delete set \(setNumber)")

            HStack(spacing: 12) {
                Text("\(setNumber)")
                    .frame(maxWidth: .infinity)

                if showsInputs {
                    TextField("-", text: $set.reps)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    TextField("-", text: $set.weight)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("-")
                        .frame(maxWidth: .infinity)

                    Text("-")
                        .frame(maxWidth: .infinity)
                }
            }
            .font(.body)
            .padding(.vertical, 4)
            .background {
                Color(.secondarySystemGroupedBackground)
                rowGradient
            }
            .offset(x: canDelete ? offset : 0)
            .gesture(
                DragGesture(minimumDistance: 12)
                    .onChanged { value in
                        guard canDelete else {
                            return
                        }

                        offset = max(-deleteButtonWidth, min(0, value.translation.width))
                    }
                    .onEnded { value in
                        guard canDelete else {
                            return
                        }

                        if value.translation.width < -revealThreshold {
                            offset = -deleteButtonWidth
                        } else {
                            offset = 0
                        }
                    }
            )
            .animation(.snappy(duration: 0.2), value: offset)
        }
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
