//
//  LBPrimaryPillButtonStyle.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

struct LBPrimaryPillButtonStyle: ButtonStyle {
    enum Variant {
        case outlined
        case filled
    }

    @Environment(\.colorScheme) private var colorScheme

    var variant: Variant = .outlined

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal)
            .frame(minHeight: 28)
            .background {
                Capsule()
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            }
            .overlay {
                Capsule()
                    .stroke(borderColor, lineWidth: borderWidth)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        switch variant {
        case .outlined:
            return LBColor.workoutStart
        case .filled:
            return Color.black
        }
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        switch variant {
        case .outlined:
            let baseOpacity = colorScheme == .dark ? 0.08 : 0.16
            return LBColor.workoutStart.opacity(isPressed ? baseOpacity + 0.08 : baseOpacity)
        case .filled:
            return LBColor.workoutStart.opacity(isPressed ? 0.82 : 1)
        }
    }

    private var borderColor: Color {
        switch variant {
        case .outlined:
            return LBColor.workoutStart
        case .filled:
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        switch variant {
        case .outlined:
            return 1.2
        case .filled:
            return 0
        }
    }
}
