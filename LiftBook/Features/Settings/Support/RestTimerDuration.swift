//
//  RestTimerDuration.swift
//  LiftBook
//
//  Created by Codex on 15/05/2026.
//

import Foundation

enum RestTimerDuration: Int, CaseIterable, Identifiable {
    case thirtySeconds = 30
    case oneMinute = 60
    case ninetySeconds = 90
    case twoMinutes = 120
    case threeMinutes = 180

    static let defaultValue: RestTimerDuration = .ninetySeconds

    init(seconds: Int) {
        self = RestTimerDuration(rawValue: seconds) ?? Self.defaultValue
    }

    var id: Int {
        rawValue
    }

    var timeInterval: TimeInterval {
        TimeInterval(rawValue)
    }

    var title: String {
        switch self {
        case .thirtySeconds:
            return "30 sec"
        case .oneMinute:
            return "1 min"
        case .ninetySeconds:
            return "1 min 30 sec"
        case .twoMinutes:
            return "2 min"
        case .threeMinutes:
            return "3 min"
        }
    }
}
