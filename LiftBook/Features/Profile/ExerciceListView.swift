//
//  ExerciceListView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 11/10/2025.
//

import SwiftUI
import SwiftData

struct ExerciceListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var exercises: [Exercise]

    var body: some View {
        List(exercises) { exercise in
            Text(exercise.name)
        }
    }
}

#Preview {
    ExerciceListView()
}
