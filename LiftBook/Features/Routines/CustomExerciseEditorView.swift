import SwiftData
import SwiftUI

struct CustomExerciseEditorMode: Identifiable {
    let id: String
    let exercise: Exercise?

    static func create() -> CustomExerciseEditorMode {
        CustomExerciseEditorMode(id: "create-\(UUID().uuidString)", exercise: nil)
    }

    static func edit(_ exercise: Exercise) -> CustomExerciseEditorMode {
        CustomExerciseEditorMode(id: "edit-\(exercise.id)", exercise: exercise)
    }

    var title: String {
        exercise == nil ? "New Exercise" : "Edit Exercise"
    }

    var saveTitle: String {
        exercise == nil ? "Create" : "Done"
    }

    var initialDraft: ExerciseDraft {
        guard let exercise else {
            return ExerciseDraft()
        }

        return ExerciseDraft(exercise: exercise)
    }
}

struct CustomExerciseEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.exerciseService) private var exerciseService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]

    let mode: CustomExerciseEditorMode

    @State private var draft: ExerciseDraft
    @State private var saveError: CustomExerciseEditorError?

    init(mode: CustomExerciseEditorMode) {
        self.mode = mode
        _draft = State(initialValue: mode.initialDraft)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    ExerciseEditorSection(title: "Basics", systemImage: "square.and.pencil") {
                        ExerciseEditorTextField(
                            title: "Name",
                            placeholder: "Incline Cable Press",
                            text: $draft.name
                        )
                        .accessibilityIdentifier("customExerciseNameField")
                    }

                    ExerciseEditorSection(
                        title: "Training Target",
                        systemImage: "figure.strengthtraining.traditional"
                    ) {
                        ExerciseEditorTextField(
                            title: "Primary muscles",
                            placeholder: "Chest, shoulders",
                            text: $draft.primaryMusclesText
                        )

                        ExerciseEditorTokenPicker(
                            values: ExerciseEditorTokens.muscles,
                            text: $draft.primaryMusclesText
                        )

                        ExerciseEditorTextField(
                            title: "Secondary muscles (optionnal)",
                            placeholder: "Triceps",
                            text: $draft.secondaryMusclesText
                        )

                        ExerciseEditorTokenPicker(
                            values: ExerciseEditorTokens.muscles,
                            text: $draft.secondaryMusclesText
                        )

                        ExerciseEditorTextField(
                            title: "Equipment",
                            placeholder: "Dumbbell, bench",
                            text: $draft.equipmentText
                        )

                        ExerciseEditorTokenPicker(
                            values: ExerciseEditorTokens.equipment,
                            text: $draft.equipmentText
                        )
                    }

                    ExerciseEditorSection(title: "Discovery", systemImage: "magnifyingglass") {
                        ExerciseEditorTextField(
                            title: "Video URL (optionnal)",
                            placeholder: "https://",
                            text: $draft.videoURLText,
                            keyboardType: .URL,
                            autocapitalization: .never,
                            autocorrectionDisabled: true
                        )
                    }

                    ExerciseEditorSection(title: "Coaching Notes", systemImage: "text.alignleft") {
                        ExerciseEditorTextArea(
                            title: "Description (optionnal)",
                            placeholder: "What this exercise is for",
                            text: $draft.descriptionText,
                            minHeight: 96
                        )

                        ExerciseEditorTextArea(
                            title: "Instructions (optionnal)",
                            placeholder: "One step per line",
                            text: $draft.instructionsText,
                            minHeight: 150
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 96)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(LBColor.background)
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(mode.saveTitle, action: saveExercise)
                        .disabled(!draft.canSave)
                }
            }
            .safeAreaInset(edge: .bottom) {
                ExerciseEditorSaveBar(
                    title: mode.saveTitle,
                    isEnabled: draft.canSave,
                    action: saveExercise
                )
            }
            .alert(item: $saveError) { error in
                Alert(
                    title: Text("Could Not Save Exercise"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func saveExercise() {
        do {
            if let exercise = mode.exercise {
                try exerciseService.updateCustomExercise(
                    exercise,
                    with: draft,
                    in: modelContext
                )
            } else {
                try exerciseService.createCustomExercise(
                    from: draft,
                    existingExercises: exercises,
                    in: modelContext
                )
            }

            dismiss()
        } catch {
            saveError = CustomExerciseEditorError(message: error.localizedDescription)
        }
    }
}

private struct CustomExerciseEditorError: Identifiable {
    let id = UUID()
    let message: String
}

private enum ExerciseEditorTokens {
    static let categories = [
        "strength",
        "cardio",
        "stretching",
        "calisthenics",
        "plyometrics",
        "olympic weightlifting"
    ]

    static let muscles = [
        "chest",
        "lats",
        "traps",
        "shoulders",
        "biceps",
        "triceps",
        "abs",
        "quads",
        "hamstrings",
        "glutes",
        "calves"
    ]

    static let equipment = [
        "none",
        "barbell",
        "dumbbell",
        "kettlebell",
        "machine",
        "cable",
        "bench",
        "bands",
        "pull-up bar"
    ]
}

private struct ExerciseEditorSection<Content: View>: View {
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

private struct ExerciseEditorTextField: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization? = .words
    var autocorrectionDisabled = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .font(.body)
                .foregroundStyle(.primary)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled(autocorrectionDisabled)
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(fieldBackground)
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.045))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
            }
    }
}

private struct ExerciseEditorTextArea: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }

                TextEditor(text: $text)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: minHeight)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(fieldBackground)
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.045))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.secondary.opacity(0.16), lineWidth: 1)
            }
    }
}

private struct ExerciseEditorTokenPicker: View {
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

    private var currentTokens: [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
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

private struct ExerciseEditorSaveBar: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: "plus.circle.fill")
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, minHeight: 54)
                .background {
                    Capsule()
                        .fill(LBColor.workoutStart)
                }
                .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.35)
        .accessibilityIdentifier("customExerciseSaveButton")
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

#Preview {
    CustomExerciseEditorView(mode: .create())
        .modelContainer(for: [Exercise.self], inMemory: true)
}
