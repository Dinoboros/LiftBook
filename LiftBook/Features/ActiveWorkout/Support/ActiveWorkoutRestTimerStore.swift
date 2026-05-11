//
//  ActiveWorkoutRestTimerStore.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ActiveWorkoutRestTimerStore {
    private let restDuration: TimeInterval
    private let restAdjustmentDuration: TimeInterval

    private(set) var deadline: Date?

    init(restDuration: TimeInterval = 90, restAdjustmentDuration: TimeInterval = 15) {
        self.restDuration = restDuration
        self.restAdjustmentDuration = restAdjustmentDuration
    }

    func start() {
        deadline = Date().addingTimeInterval(restDuration)
    }

    func skip() {
        deadline = nil
    }

    func addTime() {
        guard let deadline else {
            return
        }

        self.deadline = deadline.addingTimeInterval(restAdjustmentDuration)
    }

    func subtractTime(now: Date = Date()) {
        guard let deadline else {
            return
        }

        let adjustedDeadline = deadline.addingTimeInterval(-restAdjustmentDuration)
        self.deadline = adjustedDeadline <= now ? nil : adjustedDeadline
    }

    func remainingDuration(at date: Date) -> TimeInterval? {
        guard let deadline else {
            return nil
        }

        return remainingDuration(until: deadline, at: date)
    }

    func remainingDuration(until deadline: Date, at date: Date) -> TimeInterval {
        max(0, deadline.timeIntervalSince(date))
    }

    func expireTimer(for deadline: Date?) async {
        guard let deadline else {
            return
        }

        let sleepDuration = max(0, deadline.timeIntervalSinceNow)
        let nanoseconds = UInt64(sleepDuration * 1_000_000_000)

        do {
            try await Task.sleep(nanoseconds: nanoseconds)
        } catch {
            return
        }

        guard !Task.isCancelled, self.deadline == deadline else {
            return
        }

        self.deadline = nil
    }
}
