//
//  KeyboardDismissModifier.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

private struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done", action: dismissKeyboard)
                }
            }
    }

    private func dismissKeyboard() {
        #if canImport(UIKit)
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        #endif
    }
}

extension View {
    func appKeyboardDismissal() -> some View {
        modifier(KeyboardDismissModifier())
    }
}
