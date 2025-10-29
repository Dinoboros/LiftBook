//
//  ExerciseStore.swift
//  LiftBook
//
//  Created by Méryl VALIER on 11/10/2025.
//

import Foundation
import SwiftData

@Observable
final class ExerciseStore {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: CRUD Methods
    func getAllExercises() throws -> [Exercise] {
        []
    }
    
    func getExercise(by id: String) throws -> Exercise {
        Exercise(id: id, name: "Exercise \(id)", equipment: "Exercise \(id)", primaryMuscles: ["Exercise \(id)"], secondaryMuscles: ["Exercise \(id)"], instructions: ["Exercise \(id)"], category: "Exercise \(id)")
    }
    
    func create(_ exercise: Exercise) async throws -> Exercise {
        Exercise(id: exercise.id, name: exercise.name, equipment: exercise.equipment, primaryMuscles: exercise.primaryMuscles, secondaryMuscles: exercise.secondaryMuscles, instructions: exercise.instructions, category: exercise.category)
    }
    
    func update(_ exercise: Exercise) throws {
        
    }
    
    func delete(_ exercise: Exercise) throws {
        
    }
    
    // MARK: Search and filter methods
    func searchExercises(from name: String) async throws -> [Exercise] {
        []
    }
    
    func filterExercises(by equipment: ExerciseEquipment?) async throws -> [Exercise] {
        []
    }
    
    func searchAndFilterExercises(from name: String, equipment: ExerciseEquipment?) async throws -> [Exercise] {
        []
    }
}
