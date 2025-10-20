//
//  ExerciceListView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 11/10/2025.
//

import SwiftUI
import SwiftData

struct ExerciceListView: View {
    @Query(sort: [SortDescriptor(\Exercise.name, order: .forward)])
    private var exercises: [Exercise]

    var body: some View {
        List(exercises) { exercise in
            Text(exercise.name)
        }
        .navigationTitle(L10n.ExercisePicker.exercisesListTitle)
    }
}

#Preview {
    ExerciceListView()
}
