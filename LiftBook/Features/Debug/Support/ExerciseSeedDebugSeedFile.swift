//
//  ExerciseSeedDebugSeedFile.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

#if DEBUG
struct ExerciseSeedDebugSeedFile: Decodable {
    let exercises: [ExerciseSeedDebugExercise]
}
#endif
