//
//  MonitoringConfiguration.swift
//  LiftBook
//
//  Created by Codex on 15/05/2026.
//

import Foundation
import Sentry

enum MonitoringConfiguration {
    static let sentryDSN = "https://1789a65d3a8628045ebc94b30b8ddcc1@o4511395656564736.ingest.de.sentry.io/4511395660431440"

    static var telemetryDeckAppID: String? {
        guard let appID = Bundle.main.object(forInfoDictionaryKey: "TelemetryDeckAppID") as? String else {
            return nil
        }

        let trimmedAppID = appID.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedAppID.isEmpty ? nil : trimmedAppID
    }

    static func configureSentryOptions(_ options: Options) {
        options.dsn = sentryDSN
        options.sendDefaultPii = false
        options.tracesSampleRate = 1.0

        options.configureProfiling = {
            $0.sessionSampleRate = 1.0
            $0.lifecycle = .trace
        }
    }
}
