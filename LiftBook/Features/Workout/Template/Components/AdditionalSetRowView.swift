//
//  AdditionalSetRowView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 21/10/2025.
//

import SwiftUI

struct AdditionalSetRowView: View {
    let set: ExerciseSet
    let setNumber: Int

    var body: some View {
        HStack(spacing: 16) {
            Text("\(setNumber)")
                .frame(width: 50, alignment: .leading)
                .font(.body)

            TextField("", text: .constant("\(set.reps)"))
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .keyboardType(.numberPad)

            TextField("", text: .constant("\(set.weight)"))
                .textFieldStyle(.roundedBorder)
                .frame(width: 80)
                .keyboardType(.decimalPad)
        }
    }
}
