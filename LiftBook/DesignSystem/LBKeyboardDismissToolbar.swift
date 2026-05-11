//import SwiftUI
//import UIKit
//
//extension View {
//    func lbKeyboardDismissToolbar() -> some View {
//        background(LBKeyboardDismissAccessoryInstaller())
//    }
//}
//
//private struct LBKeyboardDismissAccessoryInstaller: UIViewRepresentable {
//    func makeUIView(context: Context) -> LBKeyboardDismissAccessoryInstallerView {
//        LBKeyboardDismissAccessoryInstallerView()
//    }
//
//    func updateUIView(_ uiView: LBKeyboardDismissAccessoryInstallerView, context: Context) {
//        uiView.installKeyboardDismissAccessories()
//    }
//}
//
//private final class LBKeyboardDismissAccessoryInstallerView: UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        isHidden = true
//        isUserInteractionEnabled = false
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        nil
//    }
//
//    override func didMoveToWindow() {
//        super.didMoveToWindow()
//        installKeyboardDismissAccessories()
//    }
//
//    func installKeyboardDismissAccessories() {
//        DispatchQueue.main.async { [weak self] in
//            self?.window?.lbInstallKeyboardDismissAccessories()
//        }
//    }
//}
//
//private final class LBKeyboardDismissAccessoryToolbar: UIToolbar {
//    init() {
//        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
//        autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        items = [
//            UIBarButtonItem.flexibleSpace(),
//            UIBarButtonItem(
//                title: "Done",
//                style: .prominent,
//                target: LBKeyboardDismissAccessoryAction.shared,
//                action: #selector(LBKeyboardDismissAccessoryAction.dismissKeyboard)
//            )
//        ]
//        sizeToFit()
//    }
//
//    @available(*, unavailable)
//    required init?(coder: NSCoder) {
//        nil
//    }
//}
//
//private final class LBKeyboardDismissAccessoryAction: NSObject {
//    static let shared = LBKeyboardDismissAccessoryAction()
//
//    @objc func dismissKeyboard() {
//        UIApplication.shared.lbDismissKeyboard()
//    }
//}
//
//extension UIApplication {
//    func lbDismissKeyboard() {
//        sendAction(
//            #selector(UIResponder.resignFirstResponder),
//            to: nil,
//            from: nil,
//            for: nil
//        )
//    }
//}
//
//private extension UIView {
//    func lbInstallKeyboardDismissAccessories() {
//        if let textField = self as? UITextField {
//            textField.lbInstallKeyboardDismissAccessory()
//        }
//
//        if let textView = self as? UITextView {
//            textView.lbInstallKeyboardDismissAccessory()
//        }
//
//        subviews.forEach { subview in
//            subview.lbInstallKeyboardDismissAccessories()
//        }
//    }
//}
//
//private extension UITextField {
//    func lbInstallKeyboardDismissAccessory() {
//        guard !(inputAccessoryView is LBKeyboardDismissAccessoryToolbar) else {
//            return
//        }
//
//        let shouldReloadInputViews = isFirstResponder
//        inputAccessoryView = LBKeyboardDismissAccessoryToolbar()
//
//        if shouldReloadInputViews {
//            reloadInputViews()
//        }
//    }
//}
//
//private extension UITextView {
//    func lbInstallKeyboardDismissAccessory() {
//        guard !(inputAccessoryView is LBKeyboardDismissAccessoryToolbar) else {
//            return
//        }
//
//        let shouldReloadInputViews = isFirstResponder
//        inputAccessoryView = LBKeyboardDismissAccessoryToolbar()
//
//        if shouldReloadInputViews {
//            reloadInputViews()
//        }
//    }
//}
