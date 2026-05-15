//
//  RestTimerNotificationService.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import Foundation
import UserNotifications

enum RestTimerNotificationAuthorizationState: Equatable {
    case notDetermined
    case denied
    case authorized
}

enum RestTimerNotificationScheduleResult: Equatable {
    case scheduled
    case disabledByPreference
    case denied
    case expired
}

struct RestTimerNotificationRequest: Equatable {
    let identifier: String
    let title: String
    let body: String
    let triggerTimeInterval: TimeInterval
    let workoutSessionID: UUID
}

protocol RestTimerNotificationScheduling {
    func authorizationState() async -> RestTimerNotificationAuthorizationState
    func requestAuthorization() async throws -> Bool
    func add(_ request: RestTimerNotificationRequest) async throws
    func removePendingNotificationRequests(withIdentifiers identifiers: [String])
    func removeDeliveredNotifications(withIdentifiers identifiers: [String])
    func restTimerNotificationIdentifiers(matchingPrefix prefix: String) async -> [String]
}

struct UserNotificationCenterRestTimerScheduler: RestTimerNotificationScheduling {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func authorizationState() async -> RestTimerNotificationAuthorizationState {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized, .provisional, .ephemeral:
            return .authorized
        @unknown default:
            return .denied
        }
    }

    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }

    func add(_ request: RestTimerNotificationRequest) async throws {
        let content = UNMutableNotificationContent()
        content.title = request.title
        content.body = request.body
        content.sound = .default
        content.userInfo = [
            "workoutSessionID": request.workoutSessionID.uuidString
        ]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, request.triggerTimeInterval),
            repeats: false
        )
        let notificationRequest = UNNotificationRequest(
            identifier: request.identifier,
            content: content,
            trigger: trigger
        )

        try await center.add(notificationRequest)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func restTimerNotificationIdentifiers(matchingPrefix prefix: String) async -> [String] {
        async let pendingRequests = center.pendingNotificationRequests()
        async let deliveredNotifications = center.deliveredNotifications()

        let pendingIdentifiers = await pendingRequests.map(\.identifier)
        let deliveredIdentifiers = await deliveredNotifications.map(\.request.identifier)
        let identifiers = pendingIdentifiers + deliveredIdentifiers

        return Array(Set(identifiers.filter { $0.hasPrefix(prefix) }))
    }
}

struct RestTimerNotificationService {
    static let identifierPrefix = "liftbook.restTimer."

    private let scheduler: RestTimerNotificationScheduling
    private let userDefaults: UserDefaults

    init(
        scheduler: RestTimerNotificationScheduling = UserNotificationCenterRestTimerScheduler(),
        userDefaults: UserDefaults = .standard
    ) {
        self.scheduler = scheduler
        self.userDefaults = userDefaults
    }

    static func identifier(for workoutSessionID: UUID) -> String {
        identifierPrefix + workoutSessionID.uuidString
    }

    static func workoutID(from identifier: String) -> UUID? {
        guard identifier.hasPrefix(identifierPrefix) else {
            return nil
        }

        let uuidString = String(identifier.dropFirst(identifierPrefix.count))
        return UUID(uuidString: uuidString)
    }

    func isEnabledByPreference() -> Bool {
        guard userDefaults.object(forKey: LBSettingsKeys.restTimerNotificationsEnabled) != nil else {
            return false
        }

        return userDefaults.bool(forKey: LBSettingsKeys.restTimerNotificationsEnabled)
    }

    func setEnabledByPreference(_ isEnabled: Bool) {
        userDefaults.set(isEnabled, forKey: LBSettingsKeys.restTimerNotificationsEnabled)
    }

    func reconcilePreferenceWithSystemAuthorization() async -> Bool {
        if await scheduler.authorizationState() == .denied {
            setEnabledByPreference(false)
            await cancelAllRestTimerNotifications()
            return false
        }

        return isEnabledByPreference()
    }

    func requestAuthorizationFromUserAction() async -> Bool {
        switch await scheduler.authorizationState() {
        case .authorized:
            setEnabledByPreference(true)
            return true
        case .denied:
            setEnabledByPreference(false)
            await cancelAllRestTimerNotifications()
            return false
        case .notDetermined:
            do {
                let isGranted = try await scheduler.requestAuthorization()
                setEnabledByPreference(isGranted)
                if !isGranted {
                    await cancelAllRestTimerNotifications()
                }
                return isGranted
            } catch {
                return false
            }
        }
    }

    @discardableResult
    func scheduleRestTimerNotification(
        workoutID: UUID,
        workoutName: String,
        deadline: Date,
        now: Date = Date()
    ) async throws -> RestTimerNotificationScheduleResult {
        guard isEnabledByPreference() else {
            cancelRestTimerNotification(for: workoutID)
            return .disabledByPreference
        }

        let triggerTimeInterval = deadline.timeIntervalSince(now)
        guard triggerTimeInterval > 0 else {
            cancelRestTimerNotification(for: workoutID)
            return .expired
        }

        try Task.checkCancellation()

        switch await scheduler.authorizationState() {
        case .authorized:
            break
        case .notDetermined:
            setEnabledByPreference(false)
            cancelRestTimerNotification(for: workoutID)
            return .denied
        case .denied:
            setEnabledByPreference(false)
            cancelRestTimerNotification(for: workoutID)
            return .denied
        }

        try Task.checkCancellation()

        let request = RestTimerNotificationRequest(
            identifier: Self.identifier(for: workoutID),
            title: "Rest is over",
            body: "Time for your next set in \(workoutName).",
            triggerTimeInterval: triggerTimeInterval,
            workoutSessionID: workoutID
        )

        cancelRestTimerNotification(for: workoutID)
        try await scheduler.add(request)
        return .scheduled
    }

    func cancelRestTimerNotification(for workoutID: UUID) {
        let identifier = Self.identifier(for: workoutID)
        scheduler.removePendingNotificationRequests(withIdentifiers: [identifier])
        scheduler.removeDeliveredNotifications(withIdentifiers: [identifier])
    }

    func cancelAllRestTimerNotifications() async {
        let identifiers = await scheduler.restTimerNotificationIdentifiers(
            matchingPrefix: Self.identifierPrefix
        )

        guard !identifiers.isEmpty else {
            return
        }

        scheduler.removePendingNotificationRequests(withIdentifiers: identifiers)
        scheduler.removeDeliveredNotifications(withIdentifiers: identifiers)
    }
}
