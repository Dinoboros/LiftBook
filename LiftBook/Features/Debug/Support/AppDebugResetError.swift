//
//  AppDebugResetError.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

#if DEBUG
import Foundation

struct AppDebugResetError: Identifiable {
    let id = UUID()
    let message: String
}
#endif
