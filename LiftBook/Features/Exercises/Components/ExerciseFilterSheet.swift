//
//  ExerciseFilterSheet.swift
//  LiftBook
//
//  Created by Codex on 14/05/2026.
//

import SwiftUI

struct ExerciseFilterSheet: View {
    @Environment(\.dismiss) private var dismiss

    let initialFilter: ExerciseLibraryFilter
    let options: ExerciseLibraryFilterOptions
    let onApply: (ExerciseLibraryFilter) -> Void

    @State private var draftFilter: ExerciseLibraryFilter
    @State private var isShowingAllEquipment = false
    @State private var isShowingAllMuscles = false

    private let columns = [
        GridItem(.adaptive(minimum: 112), spacing: 8, alignment: .leading)
    ]

    private let featuredEquipment = [
        "none",
        "barbell",
        "dumbbell",
        "machine",
        "cable",
        "bench"
    ]

    private let featuredMuscles = [
        "chest",
        "lats",
        "shoulders",
        "biceps",
        "triceps",
        "abs",
        "quads",
        "hamstrings",
        "glutes"
    ]

    init(
        initialFilter: ExerciseLibraryFilter,
        options: ExerciseLibraryFilterOptions,
        onApply: @escaping (ExerciseLibraryFilter) -> Void
    ) {
        self.initialFilter = initialFilter
        self.options = options
        self.onApply = onApply
        _draftFilter = State(initialValue: initialFilter)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        filterSection(
                            title: "Equipment",
                            systemImage: "dumbbell",
                            values: options.equipment,
                            featuredValues: featuredEquipment,
                            selectedValues: draftFilter.equipment,
                            isShowingAll: $isShowingAllEquipment,
                            isSelected: draftFilter.containsEquipment,
                            toggle: { draftFilter.toggleEquipment($0) }
                        )

                        filterSection(
                            title: "Muscles",
                            systemImage: "figure.strengthtraining.traditional",
                            values: options.muscles,
                            featuredValues: featuredMuscles,
                            selectedValues: draftFilter.muscles,
                            isShowingAll: $isShowingAllMuscles,
                            isSelected: draftFilter.containsMuscle,
                            toggle: { draftFilter.toggleMuscle($0) }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                }

                bottomActions
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                    }
                    .accessibilityLabel("Close filters")
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            draftFilter = initialFilter
        }
    }

    private func filterSection(
        title: String,
        systemImage: String,
        values: [String],
        featuredValues: [String],
        selectedValues: Set<String>,
        isShowingAll: Binding<Bool>,
        isSelected: @escaping (String) -> Bool,
        toggle: @escaping (String) -> Void
    ) -> some View {
        let visibleValues = visibleValues(
            from: values,
            featuredValues: featuredValues,
            selectedValues: selectedValues,
            isShowingAll: isShowingAll.wrappedValue
        )
        let hiddenCount = max(values.count - visibleValues.count, 0)

        return VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                ForEach(visibleValues, id: \.self) { value in
                    ExerciseFilterSheetChip(
                        title: ExerciseLibraryFilter.displayText(for: value),
                        isSelected: isSelected(value),
                        action: { toggle(value) }
                    )
                }
            }

            if values.count > visibleValues.count || isShowingAll.wrappedValue {
                Button {
                    isShowingAll.wrappedValue.toggle()
                } label: {
                    Label(
                        isShowingAll.wrappedValue ? "Show Less" : "Show More",
                        systemImage: isShowingAll.wrappedValue ? "chevron.up" : "chevron.down"
                    )
                    .font(.caption.weight(.semibold))
                }
                .buttonStyle(LBPrimaryPillButtonStyle(variant: .outlined))
                .accessibilityLabel(
                    isShowingAll.wrappedValue
                        ? "Show fewer \(title.lowercased()) filters"
                        : "Show \(hiddenCount) more \(title.lowercased()) filters"
                )
            }
        }
    }

    private func visibleValues(
        from values: [String],
        featuredValues: [String],
        selectedValues: Set<String>,
        isShowingAll: Bool
    ) -> [String] {
        guard !isShowingAll else {
            return values
        }

        let featuredSet = Set(featuredValues.map(ExerciseLibraryFilter.normalized))
        let selectedSet = Set(selectedValues.map(ExerciseLibraryFilter.normalized))

        return values.filter { value in
            let normalizedValue = ExerciseLibraryFilter.normalized(value)

            return featuredSet.contains(normalizedValue) || selectedSet.contains(normalizedValue)
        }
    }

    private var bottomActions: some View {
        HStack(spacing: 12) {
            Button {
                draftFilter = ExerciseLibraryFilter()
                isShowingAllEquipment = false
                isShowingAllMuscles = false
            } label: {
                Text("Reset")
                    .frame(minWidth: 112, minHeight: 46)
            }
            .buttonStyle(LBPrimaryPillButtonStyle(variant: .outlined))
            .accessibilityIdentifier("exerciseFilterResetButton")

            Button {
                onApply(draftFilter)
                dismiss()
            } label: {
                Text("Apply")
                    .frame(maxWidth: .infinity, minHeight: 46)
            }
            .buttonStyle(LBPrimaryPillButtonStyle(variant: .filled))
            .accessibilityIdentifier("exerciseFilterApplyButton")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

private struct ExerciseFilterSheetChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2.weight(.bold))
                        .accessibilityHidden(true)
                }

                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(isSelected ? Color.black : .primary)
            .padding(.horizontal, 11)
            .frame(maxWidth: .infinity, minHeight: 34)
            .background {
                Capsule()
                    .fill(chipBackground)
            }
            .overlay {
                Capsule()
                    .stroke(chipBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var chipBackground: Color {
        if isSelected {
            return LBColor.workoutStart
        }

        return colorScheme == .dark ? Color.white.opacity(0.07) : Color.black.opacity(0.05)
    }

    private var chipBorder: Color {
        if isSelected {
            return Color.clear
        }

        return colorScheme == .dark ? Color.white.opacity(0.12) : Color.black.opacity(0.1)
    }
}

#Preview("Filter Sheet") {
    ExerciseFilterSheet(
        initialFilter: ExerciseLibraryFilter(
            equipment: ["barbell", "bench"],
            muscles: ["chest", "triceps"]
        ),
        options: ExerciseLibraryFilterOptions(
            equipment: ExerciseEditorTokens.equipment,
            muscles: ExerciseEditorTokens.muscles
        ),
        onApply: { _ in }
    )
}
