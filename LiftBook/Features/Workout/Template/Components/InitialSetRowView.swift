//
//  InitialSetRowView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 21/10/2025.
//

import SwiftUI

struct InitialSetRowView: View {
    let setNumber: Int
    let reps: Int
    let weight: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // En-têtes des colonnes
            HStack(spacing: 16) {
                Text("Set")
                    .frame(width: 50, alignment: .leading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Reps")
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Weight")
                    .frame(width: 80, alignment: .leading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Premier set
            HStack(spacing: 16) {
                Text("\(setNumber)")
                    .frame(width: 50, alignment: .leading)
                    .font(.body)
                    
                TextField("", text: .constant("\(reps)"))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .keyboardType(.numberPad)

                TextField("", text: .constant("\(weight)"))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
                    .keyboardType(.decimalPad)
            }
        }
    }
}
