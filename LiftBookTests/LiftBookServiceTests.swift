import SwiftData
import XCTest
@testable import LiftBook

@MainActor
final class LiftBookServiceTests: XCTestCase {
    func testWorkoutHistorySourceTitlesDistinguishRoutineAndEmptyWorkouts() {
        let emptyWorkout = WorkoutSession(name: "Empty Workout")
        let routineWorkout = WorkoutSession(
            name: "Upper A",
            sourceRoutineTemplateID: UUID()
        )

        XCTAssertEqual(emptyWorkout.historySourceTitle, "Empty workout")
        XCTAssertEqual(emptyWorkout.historySourceSystemImage, "plus.circle")
        XCTAssertEqual(routineWorkout.historySourceTitle, "Routine")
        XCTAssertEqual(routineWorkout.historySourceSystemImage, "list.bullet.rectangle")
    }

    func testRoutineWorkoutCopiesTargetSetsAndValues() throws {
        let container = try LiftBookPersistence.makeModelContainer(isStoredInMemoryOnly: true)
        let modelContext = container.mainContext
        let routine = RoutineTemplate(name: "Upper A")
        let routineExercise = RoutineTemplateExercise(
            exerciseID: "bench-press",
            exerciseName: "Bench Press",
            sortOrder: 0,
            targetSets: 2
        )
        let firstSet = RoutineTemplateSet(
            sortOrder: 0,
            reps: 8,
            weight: 100
        )
        let secondSet = RoutineTemplateSet(
            sortOrder: 1,
            reps: 10,
            weight: 90
        )

        modelContext.insert(routine)
        modelContext.insert(routineExercise)
        modelContext.insert(firstSet)
        modelContext.insert(secondSet)
        routine.exercises.append(routineExercise)
        routineExercise.sets.append(firstSet)
        routineExercise.sets.append(secondSet)

        let workout = try WorkoutService().createWorkout(from: routine, in: modelContext)
        let workoutExercise = try XCTUnwrap(workout.sortedExercises.first)
        let workoutSets = workoutExercise.sortedSets

        XCTAssertEqual(workoutSets.count, 2)
        XCTAssertEqual(workoutSets[0].reps, 8)
        XCTAssertEqual(workoutSets[0].weight, 100)
        XCTAssertEqual(workoutSets[1].reps, 10)
        XCTAssertEqual(workoutSets[1].weight, 90)
    }

    func testNewRoutineExercisesDefaultToTwoSets() {
        let exercise = Exercise(
            id: "sit-up",
            name: "3/4 Sit-Up",
            category: "abs"
        )
        let draftExercise = RoutineExerciseDraft(exercise: exercise)

        XCTAssertEqual(draftExercise.sets.count, 2)
    }

    func testCustomExerciseCreationUsesUniqueIDAndPersistsFields() throws {
        let container = try LiftBookPersistence.makeModelContainer(isStoredInMemoryOnly: true)
        let modelContext = container.mainContext
        let seededExercise = Exercise(id: "custom-curl", name: "Seed Curl", category: "strength")
        var draft = ExerciseDraft()
        draft.name = " Curl "
        draft.category = "Arms"
        draft.equipmentText = "Dumbbell, Cable"
        draft.primaryMusclesText = "Biceps"
        draft.secondaryMusclesText = "Forearms"
        draft.aliasesText = "DB Curl"
        draft.descriptionText = "Controlled curl."
        draft.instructionsText = "Lift\nLower"
        draft.videoURLText = "https://example.com/curl"

        modelContext.insert(seededExercise)

        let exercise = try ExerciseService().createCustomExercise(
            from: draft,
            existingExercises: [seededExercise],
            in: modelContext
        )

        XCTAssertTrue(exercise.isCustom)
        XCTAssertEqual(exercise.id, "custom-curl-2")
        XCTAssertEqual(exercise.name, "Curl")
        XCTAssertEqual(exercise.category, "Arms")
        XCTAssertEqual(exercise.equipment, ["Dumbbell", "Cable"])
        XCTAssertEqual(exercise.primaryMuscles, ["Biceps"])
        XCTAssertEqual(exercise.secondaryMuscles, ["Forearms"])
        XCTAssertEqual(exercise.aliases, ["DB Curl"])
        XCTAssertEqual(exercise.exerciseDescription, "Controlled curl.")
        XCTAssertEqual(exercise.instructions, ["Lift", "Lower"])
        XCTAssertEqual(exercise.videoURL, "https://example.com/curl")
    }

    func testCustomExerciseUpdateKeepsStableIDAndSeededExercisesAreReadOnly() throws {
        let container = try LiftBookPersistence.makeModelContainer(isStoredInMemoryOnly: true)
        let modelContext = container.mainContext
        let service = ExerciseService()
        let customExercise = Exercise(
            id: "custom-row",
            name: "Row",
            category: "back",
            isCustom: true
        )
        let seededExercise = Exercise(id: "row", name: "Seed Row", category: "back")
        var draft = ExerciseDraft(exercise: customExercise)
        draft.name = "Chest Supported Row"
        draft.category = "Back"

        modelContext.insert(customExercise)
        modelContext.insert(seededExercise)

        try service.updateCustomExercise(customExercise, with: draft, in: modelContext)

        XCTAssertEqual(customExercise.id, "custom-row")
        XCTAssertEqual(customExercise.name, "Chest Supported Row")
        XCTAssertEqual(customExercise.category, "Back")

        XCTAssertThrowsError(
            try service.updateCustomExercise(seededExercise, with: draft, in: modelContext)
        ) { error in
            XCTAssertEqual(error as? ExerciseServiceError, .seededExerciseIsReadOnly)
        }
    }

    func testOnlyCustomExercisesCanBeDeleted() throws {
        let container = try LiftBookPersistence.makeModelContainer(isStoredInMemoryOnly: true)
        let modelContext = container.mainContext
        let service = ExerciseService()
        let customExercise = Exercise(
            id: "custom-press",
            name: "Custom Press",
            category: "push",
            isCustom: true
        )
        let seededExercise = Exercise(id: "press", name: "Seed Press", category: "push")

        modelContext.insert(customExercise)
        modelContext.insert(seededExercise)

        try service.deleteCustomExercise(customExercise, in: modelContext)

        let exercises = try modelContext.fetch(FetchDescriptor<Exercise>())
        XCTAssertFalse(exercises.contains { $0.id == "custom-press" })
        XCTAssertTrue(exercises.contains { $0.id == "press" })

        XCTAssertThrowsError(
            try service.deleteCustomExercise(seededExercise, in: modelContext)
        ) { error in
            XCTAssertEqual(error as? ExerciseServiceError, .seededExerciseIsReadOnly)
        }
    }
}
