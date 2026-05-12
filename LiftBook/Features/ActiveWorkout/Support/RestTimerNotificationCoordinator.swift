//
//  RestTimerNotificationCoordinator.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import Foundation
import Observation
import UserNotifications

@Observable
final class RestTimerNotificationCoordinator {
    static let shared = RestTimerNotificationCoordinator()

    private(set) var visibleActiveWorkoutSessionID: UUID?
    private(set) var isActiveWorkoutCovered = false
    var requestedWorkoutSessionID: UUID?

    func setActiveWorkoutVisible(_ workoutSessionID: UUID, isCovered: Bool) {
        visibleActiveWorkoutSessionID = workoutSessionID
        isActiveWorkoutCovered = isCovered
    }

    func clearActiveWorkoutVisible(_ workoutSessionID: UUID) {
        guard visibleActiveWorkoutSessionID == workoutSessionID else {
            return
        }

        visibleActiveWorkoutSessionID = nil
        isActiveWorkoutCovered = false
    }

    func setActiveWorkoutCovered(_ isCovered: Bool, for workoutSessionID: UUID) {
        guard visibleActiveWorkoutSessionID == workoutSessionID else {
            return
        }

        isActiveWorkoutCovered = isCovered
    }

    func shouldPresentForegroundNotification(for workoutSessionID: UUID) -> Bool {
        visibleActiveWorkoutSessionID != workoutSessionID || isActiveWorkoutCovered
    }

    func requestWorkoutPresentation(_ workoutSessionID: UUID) {
        requestedWorkoutSessionID = workoutSessionID
    }

    func consumeWorkoutPresentationRequest(_ workoutSessionID: UUID) {
        guard requestedWorkoutSessionID == workoutSessionID else {
            return
        }

        requestedWorkoutSessionID = nil
    }
}

final class RestTimerNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = RestTimerNotificationCenterDelegate()

    private let foregroundPresentationOptions: UNNotificationPresentationOptions = [
        .banner,
        .list,
        .sound
    ]

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        guard let workoutID = RestTimerNotificationService.workoutID(
            from: notification.request.identifier
        ) else {
            return foregroundPresentationOptions
        }

        let shouldPresent = await MainActor.run {
            RestTimerNotificationCoordinator.shared.shouldPresentForegroundNotification(
                for: workoutID
            )
        }

        return shouldPresent ? foregroundPresentationOptions : []
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard let workoutID = RestTimerNotificationService.workoutID(
            from: response.notification.request.identifier
        ) else {
            return
        }

        await MainActor.run {
            RestTimerNotificationCoordinator.shared.requestWorkoutPresentation(workoutID)
        }
    }
}
