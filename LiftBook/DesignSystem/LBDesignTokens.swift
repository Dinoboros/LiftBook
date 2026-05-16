//
//  LBDesignTokens.swift
//  LiftBook
//
//  Created by Codex on 28/04/2026.
//

import SwiftUI

enum LBColor {
    static let background = Color("AppBackground")
    static let surface = Color("AppSurface")
    static let text = Color("AppText")
    static let workoutStart = Color("WorkoutStart")
    static let destructive = Color("DestructiveColor")
    static let warning = Color("WarningColor")
}

enum LBRadius {
    static let card: CGFloat = 22
    static let chip: CGFloat = 10
}

enum LBCardLayout {
    static let scrollHorizontalPadding: CGFloat = 20

    private static let listRowHorizontalInset: CGFloat = 4

    static func listRowInsets(top: CGFloat, bottom: CGFloat) -> EdgeInsets {
        EdgeInsets(
            top: top,
            leading: listRowHorizontalInset,
            bottom: bottom,
            trailing: listRowHorizontalInset
        )
    }
}
