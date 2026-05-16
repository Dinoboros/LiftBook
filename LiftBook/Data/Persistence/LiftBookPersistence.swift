//
//  LiftBookPersistence.swift
//  LiftBook
//
//  Created by Codex on 01/05/2026.
//

import Foundation
import SwiftData

enum LiftBookPersistence {
    static var storeURL: URL {
        let baseURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory

        return baseURL
            .appendingPathComponent("LiftBook", isDirectory: true)
            .appendingPathComponent("LiftBook.store", isDirectory: false)
    }

    static var schema: Schema {
        Schema([
            Exercise.self,
            RoutineTemplate.self,
            RoutineTemplateExercise.self,
            RoutineTemplateSet.self,
            WorkoutSession.self,
            WorkoutSessionExercise.self,
            WorkoutSet.self,
        ])
    }

    static func makeModelContainer(
        isStoredInMemoryOnly: Bool = false,
        storeURL: URL? = nil
    ) throws -> ModelContainer {
        let schema = Self.schema
        let modelConfiguration: ModelConfiguration

        if isStoredInMemoryOnly {
            modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
        } else {
            let resolvedStoreURL = storeURL ?? Self.storeURL
            try createStoreDirectory(for: resolvedStoreURL)
            modelConfiguration = ModelConfiguration(
                "LiftBook",
                schema: schema,
                url: resolvedStoreURL,
                cloudKitDatabase: .none
            )
        }

        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    }

    static func deletePersistentStore(
        at storeURL: URL = Self.storeURL,
        fileManager: FileManager = .default
    ) throws {
        for url in persistentStoreFileURLs(for: storeURL) {
            guard fileManager.fileExists(atPath: url.path) else {
                continue
            }

            try fileManager.removeItem(at: url)
        }
    }

    private static func createStoreDirectory(for storeURL: URL) throws {
        try FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }

    private static func persistentStoreFileURLs(for storeURL: URL) -> [URL] {
        [
            storeURL,
            URL(fileURLWithPath: storeURL.path + "-wal"),
            URL(fileURLWithPath: storeURL.path + "-shm"),
        ]
    }
}
