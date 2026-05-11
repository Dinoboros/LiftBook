//
//  LBEmptyStateCard.swift
//  LiftBook
//
//  Created by Codex on 02/05/2026.
//

import SwiftUI

struct LBEmptyStateCard: View {
    enum Variant {
        case compact
        case prominent
    }

    let title: String
    let message: String
    let buttonTitle: String
    let buttonVariant: LBPrimaryPillButtonStyle.Variant
    let action: () -> Void
    var variant: Variant = .prominent

    var body: some View {
        VStack(alignment: contentAlignment, spacing: contentSpacing) {
            emptyIcon

            VStack(alignment: contentAlignment, spacing: 4) {
                Text(title)
                    .font(titleFont)
                    .foregroundStyle(.primary)

                Text(message)
                    .font(messageFont)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(textAlignment)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: action) {
                Label(buttonTitle, systemImage: "plus")
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(LBPrimaryPillButtonStyle(variant: buttonVariant))
            .padding(.top, buttonTopPadding)
        }
        .padding(cardPadding)
        .frame(maxWidth: maxCardWidth, minHeight: minCardHeight, alignment: cardAlignment)
        .lbCardSurface()
    }

    private var emptyIcon: some View {
        ZStack {
            Circle()
                .fill(LBColor.workoutStart.opacity(0.09))

            if variant == .prominent {
                Circle()
                    .stroke(
                        LBColor.workoutStart.opacity(0.2),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 5])
                    )
                    .padding(-8)
            }

            Image(systemName: "dumbbell.fill")
                .font(iconFont)
                .foregroundStyle(LBColor.workoutStart)
        }
        .frame(width: iconSize, height: iconSize)
        .accessibilityHidden(true)
    }

    private var contentAlignment: HorizontalAlignment {
        variant == .compact ? .leading : .center
    }

    private var cardAlignment: Alignment {
        variant == .compact ? .leading : .center
    }

    private var textAlignment: TextAlignment {
        variant == .compact ? .leading : .center
    }

    private var contentSpacing: CGFloat {
        variant == .compact ? 12 : 18
    }

    private var iconSize: CGFloat {
        variant == .compact ? 42 : 58
    }

    private var iconFont: Font {
        variant == .compact ? .callout.weight(.semibold) : .title3.weight(.semibold)
    }

    private var titleFont: Font {
        variant == .compact ? .headline.weight(.semibold) : .title3.weight(.semibold)
    }

    private var messageFont: Font {
        variant == .compact ? .caption : .subheadline
    }

    private var buttonTopPadding: CGFloat {
        variant == .compact ? 4 : 12
    }

    private var cardPadding: EdgeInsets {
        switch variant {
        case .compact:
            return EdgeInsets(top: 16, leading: 16, bottom: 14, trailing: 16)
        case .prominent:
            return EdgeInsets(top: 34, leading: 22, bottom: 22, trailing: 22)
        }
    }

    private var maxCardWidth: CGFloat? {
        switch variant {
        case .compact:
            return 250
        case .prominent:
            return .infinity
        }
    }

    private var minCardHeight: CGFloat {
        variant == .compact ? 164 : 222
    }
}

#Preview("Empty States") {
    VStack(spacing: 16) {
        LBEmptyStateCard(
            title: "No Exercises",
            message: "Add exercises to build this workout.",
            buttonTitle: "Add Exercise",
            buttonVariant: .filled,
            action: {}
        )

        HStack {
            Spacer()

            LBEmptyStateCard(
                title: "No Exercises",
                message: "Pick exercises now, edit sets later.",
                buttonTitle: "Add Exercise",
                buttonVariant: .outlined,
                action: {},
                variant: .compact
            )
        }

        LBTipCard(text: "Tip: Add a few movements to get started.")

        LBSectionEmptyStateCard(
            systemImage: "calendar",
            title: "No routines yet",
            message: "Create your first reusable plan."
        )
    }
    .padding()
    .background(LBColor.background)
    .preferredColorScheme(.dark)
}
