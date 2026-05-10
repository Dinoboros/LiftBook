//
//  PersistenceModelExtensions.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import Foundation

struct WorkoutStructureItem: Equatable {
    let exerciseID: String
    let setCount: Int
}

extension RoutineTemplate {
    var sortedExercises: [RoutineTemplateExercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    var structureItems: [WorkoutStructureItem] {
        sortedExercises.map {
            WorkoutStructureItem(
                exerciseID: $0.exerciseID,
                setCount: $0.targetSetCount
            )
        }
    }
}

extension RoutineTemplateExercise {
    var sortedSets: [RoutineTemplateSet] {
        sets.sorted { $0.sortOrder < $1.sortOrder }
    }

    var targetSetCount: Int {
        let setCount = sortedSets.count
        return max(setCount > 0 ? setCount : targetSets, 1)
    }
}

extension WorkoutSession {
    var sortedExercises: [WorkoutSessionExercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    var historySourceTitle: String {
        sourceRoutineTemplateID == nil ? "Empty workout" : "Routine"
    }

    var historySourceSystemImage: String {
        sourceRoutineTemplateID == nil ? "plus.circle" : "list.bullet.rectangle"
    }

    func elapsedDuration(at date: Date = .now) -> TimeInterval {
        max(0, (endedAt ?? date).timeIntervalSince(startedAt))
    }

    var completedDuration: TimeInterval? {
        guard let endedAt else {
            return nil
        }

        return max(0, endedAt.timeIntervalSince(startedAt))
    }

    var structureItems: [WorkoutStructureItem] {
        sortedExercises.map {
            WorkoutStructureItem(
                exerciseID: $0.exerciseID,
                setCount: max($0.sets.count, 1)
            )
        }
    }
}

extension WorkoutSessionExercise {
    var sortedSets: [WorkoutSet] {
        sets.sorted { $0.sortOrder < $1.sortOrder }
    }
}

enum WorkoutDurationFormatter {
    static func string(from duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded(.down)))
        return string(fromSeconds: totalSeconds)
    }

    static func countdownString(from duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded(.up)))
        return string(fromSeconds: totalSeconds)
    }

    private static func string(fromSeconds totalSeconds: Int) -> String {
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours):" + String(format: "%02d:%02d", minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }
}
