//
//  DebugAccessModifier.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct DebugAccessModifier: ViewModifier {
    @State private var isShowingDebug = false

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture(count: 4)
                    .onEnded(showDebug)
            )
            .sheet(isPresented: $isShowingDebug) {
                NavigationStack {
                    AppDebugView()
                }
            }
    }

    private func showDebug() {
        isShowingDebug = true
    }
}

extension View {
    func debugAccess() -> some View {
        modifier(DebugAccessModifier())
    }
}
