//
//  ExerciseDetailView.swift
//  LiftBook
//
//  Created by Codex on 12/05/2026.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    init(exercise: Exercise) {
        self.exercise = exercise
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                headerCard

                ExerciseDetailSection(title: "Muscles", systemImage: "figure.strengthtraining.traditional") {
                    if hasMuscles {
                        ExerciseDetailValueRow(title: "Primary") {
                            ExerciseDetailChipGroup(values: exercise.primaryMuscles)
                        }

                        ExerciseDetailValueRow(title: "Secondary") {
                            ExerciseDetailChipGroup(values: exercise.secondaryMuscles)
                        }
                    } else {
                        ExerciseDetailFallbackText("No muscles listed.")
                    }
                }

                ExerciseDetailSection(title: "Equipment", systemImage: "dumbbell") {
                    if exercise.equipment.isEmpty {
                        ExerciseDetailFallbackText("No equipment listed.")
                    } else {
                        ExerciseDetailChipGroup(values: exercise.equipment)
                    }
                }

                ExerciseDetailSection(title: "Description", systemImage: "text.alignleft") {
                    Text(descriptionText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ExerciseDetailSection(title: "Instructions", systemImage: "list.number") {
                    if exercise.instructions.isEmpty {
                        ExerciseDetailFallbackText("No instructions available.")
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                                ExerciseDetailInstructionRow(
                                    number: index + 1,
                                    instruction: instruction
                                )
                            }
                        }
                    }
                }

                if let videoURL {
                    ExerciseDetailSection(title: "Video URL", systemImage: "play.rectangle") {
                        Link(destination: videoURL) {
                            Label(videoURL.absoluteString, systemImage: "link")
                                .font(.subheadline)
                                .foregroundStyle(LBColor.workoutStart)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
            .padding(.horizontal, LBCardLayout.scrollHorizontalPadding)
            .padding(.top, 18)
            .padding(.bottom, 32)
        }
        .background(LBColor.background.ignoresSafeArea())
        .navigationTitle("Exercise")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                if !exercise.category.isEmpty {
                    LBInfoChip(
                        systemImage: "tag",
                        text: exercise.category.capitalized
                    )
                }

                if exercise.isCustom {
                    LBInfoChip(
                        systemImage: "square.and.pencil",
                        text: "Custom",
                        tint: .secondary
                    )
                }
            }

            if let exerciseDescription = exercise.exerciseDescription, !exerciseDescription.isEmpty {
                Text(exerciseDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lbCardSurface()
    }

    private var hasMuscles: Bool {
        !exercise.primaryMuscles.isEmpty || !exercise.secondaryMuscles.isEmpty
    }

    private var descriptionText: String {
        guard let exerciseDescription = exercise.exerciseDescription, !exerciseDescription.isEmpty else {
            return "No description available."
        }

        return exerciseDescription
    }

    private var videoURL: URL? {
        guard let videoURLText = exercise.videoURL else {
            return nil
        }

        return URL(string: videoURLText)
    }
}

private struct ExerciseDetailSection<Content: View>: View {
    let title: String
    let systemImage: String
    private let content: Content

    init(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lbCardSurface()
    }
}

private struct ExerciseDetailValueRow<Content: View>: View {
    let title: String
    private let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            content
        }
    }
}

private struct ExerciseDetailChipGroup: View {
    let values: [String]

    var body: some View {
        if values.isEmpty {
            ExerciseDetailFallbackText("None")
        } else {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 92), spacing: 8, alignment: .leading)
                ],
                alignment: .leading,
                spacing: 8
            ) {
                ForEach(values, id: \.self) { value in
                    LBInfoChip(
                        systemImage: "circle.fill",
                        text: value.capitalized
                    )
                }
            }
        }
    }
}

private struct ExerciseDetailInstructionRow: View {
    let number: Int
    let instruction: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number).")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .leading)

            Text(instruction)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ExerciseDetailFallbackText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

#Preview("Populated") {
    NavigationStack {
        ExerciseDetailView(
            exercise: Exercise(
                id: "close-grip-bench-press",
                name: "Close-Grip Bench Press",
                category: "strength",
                exerciseDescription: "Flat bench press performed with a close grip on a barbell",
                equipment: ["barbell", "bench"],
                instructions: [
                    "Lie back on a flat bench. Using a close grip, lift the bar from the rack and hold it over you.",
                    "Come down slowly until you feel the bar on your middle chest while keeping elbows close.",
                    "Press the bar back to the starting position as you breathe out.",
                    "Repeat the movement for the prescribed amount of repetitions."
                ],
                primaryMuscles: ["triceps"],
                secondaryMuscles: ["chest", "shoulders"],
                videoURL: "https://www.youtube.com/watch?v=XEnAUu6WtSw"
            )
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Minimal Custom") {
    NavigationStack {
        ExerciseDetailView(
            exercise: Exercise(
                id: "custom-movement",
                name: "Custom Movement",
                category: "strength",
                isCustom: true
            )
        )
    }
    .preferredColorScheme(.dark)
}
