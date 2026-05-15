//
//  AppMonitoring.swift
//  LiftBook
//
//  Created by Codex on 15/05/2026.
//

import Sentry
import TelemetryDeck

enum AppMonitoring {
    static func initialize() {
        initializeSentry()
        initializeTelemetryDeck()
    }

    private static func initializeSentry() {
        SentrySDK.start { options in
            MonitoringConfiguration.configureSentryOptions(options)
        }
    }

    private static func initializeTelemetryDeck() {
        guard let appID = MonitoringConfiguration.telemetryDeckAppID else {
            return
        }

        let config = TelemetryDeck.Config(appID: appID)
        TelemetryDeck.initialize(config: config)
        AnalyticsTracker.enable()
    }
}
