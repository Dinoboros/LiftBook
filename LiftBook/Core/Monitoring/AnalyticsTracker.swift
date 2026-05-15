//
//  AnalyticsTracker.swift
//  LiftBook
//
//  Created by Codex on 15/05/2026.
//

import TelemetryDeck

@MainActor
enum AnalyticsTracker {
    private static var isEnabled = false

    static func enable() {
        isEnabled = true
    }

    static func track(_ event: AnalyticsEvent) {
        guard isEnabled else {
            return
        }

        TelemetryDeck.signal(event.name, parameters: event.parameters)
    }
}
