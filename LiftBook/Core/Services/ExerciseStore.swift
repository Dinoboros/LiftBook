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
    var searchQuery: String = ""
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Importe les exercices depuis le fichier JSON bundled dans l'application
    ///
    /// Cette fonction effectue les opérations suivantes :
    /// 1. **Vérification** : Contrôle si des exercices sont déjà présents en base
    /// 2. **Lecture** : Charge le fichier exercises.json depuis le bundle
    /// 3. **Décodage** : Parse le JSON avec gestion d'erreurs détaillée
    /// 4. **Insertion** : Insère les exercices en base avec sauvegardes périodiques
    /// 5. **Progression** : Rapporte l'avancement via le callback de progression
    ///
    /// - Parameter progress: Closure appelée sur le thread principal pour reporter
    ///   la progression (0.0 à 1.0) et le statut textuel de l'opération
    /// - Throws: `NSError` avec codes spécifiques :
    ///   - Code 1 : Fichier JSON introuvable
    ///   - Code 2-5 : Erreurs de décodage JSON (clé manquante, valeur manquante,
    ///     type mismatch, données corrompues)
    ///
    /// - Note: L'opération est **idempotente** - si les exercices sont déjà importés,
    ///   la fonction termine immédiatement avec progression 100%
    /// - Note: Les opérations de base de données sont automatiquement dispatchées
    ///   sur le thread principal pour la sécurité des threads
    /// - Note: Sauvegarde par batches de 200 éléments pour optimiser les performances
    /// - Note: Mise à jour de progression tous les 25 éléments pour fluidité UI
    ///
    /// ## Exemple d'utilisation :
    /// ```swift
    /// let store = ExerciseStore(modelContext: context)
    /// try await store.loadExercisesFromJSON { progress, status in
    ///     print("Progression: \(Int(progress * 100))% - \(status)")
    /// }
    /// ```
    func loadExercisesFromJSON(progress: @MainActor (_ progress: Double, _ status: String) -> Void = { _, _ in }) async throws {
        await MainActor.run {
            progress(0, "Loading exercises…")
        }
        
        if try hasAnyExercise() {
            await MainActor.run {
                progress(1, "Already imported")
            }
            return
        }
        
        await MainActor.run {
            progress(0.05, "Reading file…")
        }
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            throw NSError(domain: "ExerciseStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fichier exercises.json introuvable"])
        }
        let data = try Data(contentsOf: url)
        
        await MainActor.run {
            progress(0.1, "Decoding JSON…")
        }
        let decoder = JSONDecoder()
        let items: [Exercise]
        do {
            items = try decoder.decode([Exercise].self, from: data)
        } catch let DecodingError.keyNotFound(key, context) {
            throw NSError(domain: "ExerciseStore", code: 2, userInfo: [NSLocalizedDescriptionKey: "Clé manquante dans le JSON: \(key.stringValue) (path: \(context.codingPath.map(\.stringValue).joined(separator: ".")))"])
        } catch let DecodingError.valueNotFound(type, context) {
            throw NSError(domain: "ExerciseStore", code: 3, userInfo: [NSLocalizedDescriptionKey: "Valeur manquante pour type \(type) (path: \(context.codingPath.map(\.stringValue).joined(separator: ".")))"])
        } catch let DecodingError.typeMismatch(type, context) {
            throw NSError(domain: "ExerciseStore", code: 4, userInfo: [NSLocalizedDescriptionKey: "Type mismatch pour \(type) (path: \(context.codingPath.map(\.stringValue).joined(separator: ".")))"])
        } catch let DecodingError.dataCorrupted(context) {
            throw NSError(domain: "ExerciseStore", code: 5, userInfo: [NSLocalizedDescriptionKey: "JSON corrompu: \(context.debugDescription)"])
        } catch {
            throw error
        }
        let total = max(items.count, 1)
        var lastReported = 0
        
        for (index, item) in items.enumerated() {
            await MainActor.run {
                modelContext.insert(item)
            }
            
            if index % 200 == 0 && index > 0 {
                try await MainActor.run {
                    try modelContext.save()
                }
            }
            
            if index - lastReported >= 25 || index == total - 1 {
                lastReported = index
                let fraction = 0.1 + (0.85 * (Double(index + 1) / Double(total)))
                let status = "Import \(index + 1)/\(total)"
                await MainActor.run {
                    progress(min(fraction, 0.95), status)
                }
                await Task.yield()
            }
        }
        
        try await MainActor.run {
            try modelContext.save()
        }
        await MainActor.run {
            progress(1.0, "Done")
        }
    }
    
    private func hasAnyExercise() throws -> Bool {
        var descriptor = FetchDescriptor<Exercise>()
        descriptor.fetchLimit = 1
        let any = try modelContext.fetch(descriptor)
        return !any.isEmpty
    }
    
    private func purgeAllExercises() throws {
        let all = try modelContext.fetch(FetchDescriptor<Exercise>())
        for e in all { modelContext.delete(e) }
        try modelContext.save()
    }
}
