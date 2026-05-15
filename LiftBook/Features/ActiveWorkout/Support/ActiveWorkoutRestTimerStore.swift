//
//  ActiveWorkoutRestTimerStore.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation

final class ActiveWorkoutRestTimerStore {
    private let restDuration: TimeInterval
    private let restAdjustmentDuration: TimeInterval

    init(restDuration: TimeInterval = 90, restAdjustmentDuration: TimeInterval = 15) {
        self.restDuration = restDuration
        self.restAdjustmentDuration = restAdjustmentDuration
    }

    func startDeadline(now: Date = Date()) -> Date {
        now.addingTimeInterval(restDuration)
    }

    func startDeadline(restDuration: TimeInterval, now: Date = Date()) -> Date {
        now.addingTimeInterval(restDuration)
    }

    func deadlineByAddingTime(to deadline: Date) -> Date {
        deadline.addingTimeInterval(restAdjustmentDuration)
    }

    func deadlineBySubtractingTime(from deadline: Date, now: Date = Date()) -> Date? {
        let adjustedDeadline = deadline.addingTimeInterval(-restAdjustmentDuration)
        return adjustedDeadline <= now ? nil : adjustedDeadline
    }

    func remainingDuration(until deadline: Date, at date: Date) -> TimeInterval {
        max(0, deadline.timeIntervalSince(date))
    }

    func waitUntilExpired(for deadline: Date?) async -> Bool {
        guard let deadline else {
            return false
        }

        let sleepDuration = max(0, deadline.timeIntervalSinceNow)
        let nanoseconds = UInt64(sleepDuration * 1_000_000_000)

        do {
            try await Task.sleep(nanoseconds: nanoseconds)
        } catch {
            return false
        }

        return !Task.isCancelled
    }
}
