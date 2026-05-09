//
//  LBExerciseCardStyle.swift
//  LiftBook
//
//  Created by Codex on 09/05/2026.
//

import SwiftUI

enum LBExerciseCardMetrics {
    static let cardCornerRadius: CGFloat = 8
    static let rowCornerRadius: CGFloat = 8
    static let rowHeight: CGFloat = 46
    static let setNumberWidth: CGFloat = 52
    static let completionWidth: CGFloat = 48
    static let deleteRevealWidth: CGFloat = 74
}

struct LBExpandedExerciseCardSurface: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background {
                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                    style: .continuous
                )
                .fill(.regularMaterial)

                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                    style: .continuous
                )
                .fill(surfaceTint)

                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                    style: .continuous
                )
                .fill(surfaceSheen)
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.cardCornerRadius,
                    style: .continuous
                )
                .stroke(borderColor, lineWidth: 1)
            }
    }

    private var surfaceTint: Color {
        if colorScheme == .dark {
            return LBColor.surface.opacity(0.72)
        }

        return LBColor.surface.opacity(0.82)
    }

    private var surfaceSheen: LinearGradient {
        let topOpacity = colorScheme == .dark ? 0.09 : 0.55
        let bottomOpacity = colorScheme == .dark ? 0.02 : 0.14

        return LinearGradient(
            colors: [
                Color.white.opacity(topOpacity),
                Color.white.opacity(bottomOpacity)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.17) : Color.black.opacity(0.12)
    }
}

struct LBExerciseSetTableHeader: View {
    let showsCompletionColumn: Bool

    var body: some View {
        HStack(spacing: 0) {
            Text("Set #")
                .frame(width: LBExerciseCardMetrics.setNumberWidth)

            Text("Reps")
                .frame(maxWidth: .infinity)

            Text("Weight (kg)")
                .frame(maxWidth: .infinity)

            if showsCompletionColumn {
                Color.clear
                    .frame(width: LBExerciseCardMetrics.completionWidth)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.secondary)
    }
}

struct LBExerciseSetRowBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    let isCompleted: Bool

    var body: some View {
        RoundedRectangle(
            cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
            style: .continuous
        )
        .fill(baseColor)
        .overlay {
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                style: .continuous
            )
            .fill(highlight)
        }
        .overlay {
            RoundedRectangle(
                cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                style: .continuous
            )
            .stroke(borderColor, lineWidth: 1)
        }
    }

    private var baseColor: Color {
        if colorScheme == .dark {
            return Color.white.opacity(isCompleted ? 0.06 : 0.035)
        }

        return Color.black.opacity(isCompleted ? 0.05 : 0.025)
    }

    private var highlight: Color {
        if isCompleted {
            return LBColor.workoutStart.opacity(colorScheme == .dark ? 0.16 : 0.12)
        }

        return Color.clear
    }

    private var borderColor: Color {
        if isCompleted {
            return LBColor.workoutStart.opacity(0.65)
        }

        return colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.12)
    }
}

struct LBExerciseSetColumnDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.secondary.opacity(0.22))
            .frame(width: 1)
    }
}

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

struct LBAddSetButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(LBColor.workoutStart)
            .frame(maxWidth: .infinity, minHeight: 38)
            .background {
                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                    style: .continuous
                )
                .fill(backgroundColor(isPressed: configuration.isPressed))
            }
            .overlay {
                RoundedRectangle(
                    cornerRadius: LBExerciseCardMetrics.rowCornerRadius,
                    style: .continuous
                )
                .stroke(borderColor, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        let baseOpacity = colorScheme == .dark ? 0.025 : 0.04
        return LBColor.workoutStart.opacity(isPressed ? baseOpacity + 0.06 : baseOpacity)
    }

    private var borderColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.11)
    }
}

extension View {
    func lbExpandedExerciseCardSurface() -> some View {
        modifier(LBExpandedExerciseCardSurface())
    }
}
