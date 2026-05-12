//
//  ExerciseEditorTokenPicker.swift
//  LiftBook
//
//  Created by Codex on 11/05/2026.
//

import SwiftUI

struct ExerciseEditorTokenPicker: View {
    @Environment(\.colorScheme) private var colorScheme

    let values: [String]
    @Binding var text: String
    var allowsMultipleSelection = true

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(values, id: \.self) { value in
                    Button {
                        toggle(value)
                    } label: {
                        Text(displayText(for: value))
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .foregroundStyle(isSelected(value) ? Color.black : .primary)
                            .padding(.horizontal, 11)
                            .frame(height: 30)
                            .background {
                                Capsule()
                                    .fill(chipBackground(for: value))
                            }
                            .overlay {
                                Capsule()
                                    .stroke(chipBorder(for: value), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 1)
        }
    }

    private var currentTokens: [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func toggle(_ value: String) {
        if allowsMultipleSelection {
            toggleToken(value)
        } else {
            text = value
        }
    }

    private func toggleToken(_ value: String) {
        var tokens = currentTokens
        let normalizedValue = normalized(value)

        if let index = tokens.firstIndex(where: { normalized($0) == normalizedValue }) {
            tokens.remove(at: index)
        } else {
            tokens.append(value)
        }

        text = tokens.joined(separator: ", ")
    }

    private func isSelected(_ value: String) -> Bool {
        if allowsMultipleSelection {
            return currentTokens.contains { normalized($0) == normalized(value) }
        }

        return normalized(text.trimmingCharacters(in: .whitespacesAndNewlines)) == normalized(value)
    }

    private func displayText(for value: String) -> String {
        value.capitalized
    }

    private func chipBackground(for value: String) -> Color {
        if isSelected(value) {
            return LBColor.workoutStart
        }

        return colorScheme == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.05)
    }

    private func chipBorder(for value: String) -> Color {
        if isSelected(value) {
            return Color.clear
        }

        return colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.1)
    }

    private func normalized(_ value: String) -> String {
        value.lowercased()
    }
}
