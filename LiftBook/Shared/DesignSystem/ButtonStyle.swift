//
//  ButtonStyle.swift
//  LiftBook
//
//  Created by Méryl VALIER on 11/10/2025.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}