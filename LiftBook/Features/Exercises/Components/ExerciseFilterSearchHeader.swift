//
//  ExerciseFilterSearchHeader.swift
//  LiftBook
//
//  Created by Codex on 14/05/2026.
//

import SwiftUI

struct ExerciseFilterSearchHeader: View {
    @Binding var searchText: String
    @Binding var filter: ExerciseLibraryFilter

    let onShowFilters: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            searchBar

            if filter.isActive {
                ExerciseActiveFilterBar(filter: $filter)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .focusedValue(\.lbKeyboardDismissAction, {
            isSearchFocused = false
        })
        .animation(.snappy(duration: 0.18), value: filter)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            TextField("Search", text: $searchText)
                .font(.title3)
                .foregroundStyle(.primary)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isSearchFocused)
                .accessibilityIdentifier("exerciseSearchField")

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }

            Divider()
                .frame(height: 28)

            ExerciseFilterButton(
                activeCount: filter.activeCount,
                action: onShowFilters
            )
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(searchBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(searchBorder, lineWidth: 1)
        }
    }

    private var searchBackground: Color {
        colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
    }

    private var searchBorder: Color {
        colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.08)
    }
}

private struct ExerciseFilterButton: View {
    let activeCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: activeCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundStyle(activeCount > 0 ? LBColor.workoutStart : .primary)
                    .frame(width: 34, height: 34)

                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(minWidth: 17, minHeight: 17)
                        .padding(.horizontal, activeCount > 9 ? 3 : 0)
                        .background {
                            Capsule()
                                .fill(LBColor.workoutStart)
                        }
                        .offset(x: 6, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Filters")
        .accessibilityValue(activeCount > 0 ? "\(activeCount) active" : "No active filters")
        .accessibilityIdentifier("exerciseFilterButton")
    }
}

private struct ExerciseActiveFilterBar: View {
    @Binding var filter: ExerciseLibraryFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filter.sortedEquipment, id: \.self) { value in
                    activeChip(
                        title: ExerciseLibraryFilter.displayText(for: value),
                        accessibilityPrefix: "Remove equipment filter",
                        action: { filter.removeEquipment(value) }
                    )
                }

                ForEach(filter.sortedMuscles, id: \.self) { value in
                    activeChip(
                        title: ExerciseLibraryFilter.displayText(for: value),
                        accessibilityPrefix: "Remove muscle filter",
                        action: { filter.removeMuscle(value) }
                    )
                }

                Button("Clear") {
                    filter = ExerciseLibraryFilter()
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background {
                    Capsule()
                        .fill(Color.secondary.opacity(0.12))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear all filters")
            }
            .padding(.vertical, 1)
        }
    }

    private func activeChip(
        title: String,
        accessibilityPrefix: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .lineLimit(1)

                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .accessibilityHidden(true)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.black)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background {
                Capsule()
                    .fill(LBColor.workoutStart)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(accessibilityPrefix) \(title)")
    }
}

struct ExerciseFilterNoResultsView: View {
    let searchText: String
    let isFilterActive: Bool

    var body: some View {
        ContentUnavailableView(
            "No Matching Exercises",
            systemImage: "line.3.horizontal.decrease.circle",
            description: Text(description)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var description: String {
        let trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedSearchText.isEmpty, isFilterActive {
            return "Try changing your search or filters."
        }

        if isFilterActive {
            return "Try changing or clearing your filters."
        }

        return "Try a different search."
    }
}

#Preview("Search Header") {
    ExerciseFilterSearchHeaderPreview()
        .padding()
        .background(LBColor.background)
}

private struct ExerciseFilterSearchHeaderPreview: View {
    @State private var searchText = "bench"
    @State private var filter = ExerciseLibraryFilter(
        equipment: ["barbell", "dumbbell"],
        muscles: ["chest", "shoulders"]
    )

    var body: some View {
        ExerciseFilterSearchHeader(
            searchText: $searchText,
            filter: $filter,
            onShowFilters: {}
        )
    }
}
