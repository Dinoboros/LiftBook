import SwiftData
import SwiftUI

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
        .debugAccess()
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

#Preview {
    CustomExerciseEditorView(mode: .create())
        .modelContainer(for: [Exercise.self], inMemory: true)
}
