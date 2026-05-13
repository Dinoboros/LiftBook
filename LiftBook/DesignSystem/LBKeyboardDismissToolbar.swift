import SwiftUI
import UIKit

extension View {
    func lbKeyboardDismissToolbar() -> some View {
        modifier(LBKeyboardDismissToolbar())
    }
}

private struct LBKeyboardDismissActionKey: FocusedValueKey {
    typealias Value = () -> Void
}

extension FocusedValues {
    var lbKeyboardDismissAction: (() -> Void)? {
        get { self[LBKeyboardDismissActionKey.self] }
        set { self[LBKeyboardDismissActionKey.self] = newValue }
    }
}

private struct LBKeyboardDismissToolbar: ViewModifier {
    @FocusedValue(\.lbKeyboardDismissAction) private var dismissKeyboard

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Done") {
                        if let dismissKeyboard {
                            dismissKeyboard()
                        } else {
                            UIApplication.shared.lbDismissKeyboard()
                        }
                    }
                    .fontWeight(.semibold)
                    .accessibilityLabel("Dismiss keyboard")
                }
            }
    }
}

private extension UIApplication {
    func lbDismissKeyboard() {
        sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
