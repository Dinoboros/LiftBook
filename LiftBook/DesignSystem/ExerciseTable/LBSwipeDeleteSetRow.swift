//
//  LBSwipeDeleteSetRow.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct LBSwipeDeleteSetRow<Content: View>: View {
    let canDelete: Bool
    let deleteAccessibilityLabel: String
    let onDelete: () -> Void
    let content: () -> Content

    @GestureState private var dragTranslation: CGFloat = 0
    @State private var isDeleteRevealed = false

    init(
        canDelete: Bool,
        deleteAccessibilityLabel: String,
        onDelete: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.canDelete = canDelete
        self.deleteAccessibilityLabel = deleteAccessibilityLabel
        self.onDelete = onDelete
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            content()
                .offset(x: canDelete ? currentOffset : 0)
                .contentShape(Rectangle())
                .gesture(deleteRevealGesture)

            deleteButton
                .opacity(canDelete && currentOffset < 0 ? 1 : 0)
                .allowsHitTesting(canDelete && isDeleteRevealed)
        }
        .frame(maxWidth: .infinity, minHeight: LBExerciseCardMetrics.rowHeight)
        .clipShape(
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                style: .continuous
            )
        )
        .animation(.snappy(duration: 0.2), value: isDeleteRevealed)
        .accessibilityAction(named: Text(deleteAccessibilityLabel)) {
            guard canDelete else {
                return
            }

            deleteSet()
        }
    }

    private var currentOffset: CGFloat {
        let baseOffset = isDeleteRevealed ? -LBExerciseCardMetrics.deleteRevealWidth : 0
        let proposedOffset = baseOffset + dragTranslation
        return min(0, max(-LBExerciseCardMetrics.deleteRevealWidth, proposedOffset))
    }

    private var deleteButton: some View {
        Button(role: .destructive, action: deleteSet) {
            VStack(spacing: 4) {
                Image(systemName: "trash")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(
                width: LBExerciseCardMetrics.deleteRevealWidth,
                height: LBExerciseCardMetrics.rowHeight
            )
            .background(LBColor.destructive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(deleteAccessibilityLabel)
    }

    private var deleteRevealGesture: some Gesture {
        DragGesture(minimumDistance: 14)
            .updating($dragTranslation) { value, state, _ in
                guard canDelete, abs(value.translation.width) > abs(value.translation.height) else {
                    return
                }

                state = value.translation.width
            }
            .onEnded { value in
                guard canDelete, abs(value.translation.width) > abs(value.translation.height) else {
                    return
                }

                let baseOffset = isDeleteRevealed ? -LBExerciseCardMetrics.deleteRevealWidth : 0
                let predictedOffset = baseOffset + value.predictedEndTranslation.width
                isDeleteRevealed = predictedOffset < -LBExerciseCardMetrics.deleteRevealWidth / 2
            }
    }

    private func deleteSet() {
        isDeleteRevealed = false
        onDelete()
    }
}
