import SwiftData
import XCTest
@testable import LiftBook

@MainActor
final class LiftBookServiceTests: XCTestCase {
    func testWeightFormatterConvertsBetweenKilogramsAndPounds() {
        XCTAssertEqual(
            LBWeightFormatter.displayText(forKilograms: 100, unit: .kilograms),
            "100"
        )
        XCTAssertEqual(
            LBWeightFormatter.displayText(forKilograms: 100, unit: .pounds),
            "220.5"
        )
        XCTAssertEqual(
            LBWeightFormatter.kilograms(fromDisplayText: "220.5", unit: .pounds) ?? 0,
            100,
            accuracy: 0.05
        )
        XCTAssertNil(LBWeightFormatter.kilograms(fromDisplayText: "abc", unit: .pounds))
        XCTAssertNil(LBWeightFormatter.kilograms(fromDisplayText: "", unit: .kilograms))
    }

    func testRoutineSetDraftPreservesStoredKilogramsWhenPoundTextIsUnchanged() {
        let set = RoutineTemplateSet(sortOrder: 0, reps: 8, weight: 100)
        let draft = RoutineSetDraft(set: set, weightUnit: .pounds)

        XCTAssertEqual(draft.weight, "220.5")
        XCTAssertEqual(draft.weightValue(unit: .pounds), 100)
    }

    func testRoutineCreationStoresPoundDisplayWeightAsKilograms() throws {
        let container = try LiftBookPersistence.makeModelContainer(isStoredInMemoryOnly: true)
        let modelContext = container.mainContext
        let exercise = Exercise(
            id: "bench-press",
            name: "Bench Press",
            category: "strength"
        )
        var draft = RoutineDraft()
        draft.name = "Upper A"
        draft.addExercises([exercise])
        draft.exercises[0].sets[0].reps = "8"
        draft.exercises[0].sets[0].weight = "220.5"

        let routine = try RoutineService().create(
            from: draft,
            weightUnit: .pounds,
            in: modelContext
        )
        let set = try XCTUnwrap(routine.sortedExercises.first?.sortedSets.first)

        XCTAssertEqual(set.reps, 8)
        XCTAssertEqual(set.weight ?? 0, 100, accuracy: 0.05)
    }

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

    func testRestTimerDateMathUsesConfiguredDurations() {
        let timer = ActiveWorkoutRestTimerStore(restDuration: 90, restAdjustmentDuration: 15)
        let now = Date(timeIntervalSince1970: 1_000)

        let deadline = timer.startDeadline(now: now)
        let addedDeadline = timer.deadlineByAddingTime(to: deadline)
        let subtractedDeadline = timer.deadlineBySubtractingTime(from: addedDeadline, now: now)
        let expiredDeadline = timer.deadlineBySubtractingTime(
            from: now.addingTimeInterval(10),
            now: now
        )

        XCTAssertEqual(deadline.timeIntervalSince(now), 90, accuracy: 0.001)
        XCTAssertEqual(addedDeadline.timeIntervalSince(now), 105, accuracy: 0.001)
        XCTAssertEqual(subtractedDeadline?.timeIntervalSince(now) ?? 0, 90, accuracy: 0.001)
        XCTAssertNil(expiredDeadline)
        XCTAssertEqual(
            WorkoutDurationFormatter.countdownString(from: timer.remainingDuration(until: deadline, at: now)),
            "01:30"
        )
    }

    func testWorkoutServicePersistsAndClearsRestTimerDeadline() throws {
        let container = try LiftBookPersistence.makeModelContainer(isStoredInMemoryOnly: true)
        let modelContext = container.mainContext
        let service = WorkoutService()
        let workout = WorkoutSession()
        let deadline = Date(timeIntervalSince1970: 2_000)

        modelContext.insert(workout)
        try service.setRestTimerDeadline(deadline, for: workout, in: modelContext)

        XCTAssertEqual(workout.restTimerDeadline, deadline)
        XCTAssertFalse(
            try service.clearExpiredRestTimer(
                for: workout,
                at: deadline.addingTimeInterval(-1),
                in: modelContext
            )
        )

        XCTAssertTrue(
            try service.clearExpiredRestTimer(
                for: workout,
                at: deadline,
                in: modelContext
            )
        )
        XCTAssertNil(workout.restTimerDeadline)

        try service.setRestTimerDeadline(deadline, for: workout, in: modelContext)
        try service.finish(workout, updateSourceRoutine: false, in: modelContext)
        XCTAssertNil(workout.restTimerDeadline)
    }

    func testRestTimerNotificationServiceSchedulesReplacementRequest() async throws {
        let scheduler = FakeRestTimerNotificationScheduler(authorizationState: .authorized)
        let userDefaults = try makeEphemeralUserDefaults()
        let service = RestTimerNotificationService(
            scheduler: scheduler,
            userDefaults: userDefaults
        )
        let workoutID = try XCTUnwrap(UUID(uuidString: "F18F542B-65AD-4C32-A866-3D8FC1117F86"))
        let now = Date(timeIntervalSince1970: 1_000)

        let firstResult = try await service.scheduleRestTimerNotification(
            workoutID: workoutID,
            workoutName: "Upper A",
            deadline: now.addingTimeInterval(90),
            now: now
        )
        let secondResult = try await service.scheduleRestTimerNotification(
            workoutID: workoutID,
            workoutName: "Upper A",
            deadline: now.addingTimeInterval(105),
            now: now
        )

        let identifier = RestTimerNotificationService.identifier(for: workoutID)
        XCTAssertEqual(firstResult, .scheduled)
        XCTAssertEqual(secondResult, .scheduled)
        XCTAssertEqual(scheduler.addedRequests.count, 2)
        XCTAssertEqual(scheduler.addedRequests[0].identifier, identifier)
        XCTAssertEqual(scheduler.addedRequests[0].title, "Rest is over")
        XCTAssertEqual(scheduler.addedRequests[0].body, "Time for your next set in Upper A.")
        XCTAssertEqual(scheduler.addedRequests[0].triggerTimeInterval, 90, accuracy: 0.001)
        XCTAssertEqual(scheduler.addedRequests[1].identifier, identifier)
        XCTAssertEqual(scheduler.addedRequests[1].triggerTimeInterval, 105, accuracy: 0.001)
        XCTAssertEqual(scheduler.removedPendingIdentifiers, [identifier, identifier])
        XCTAssertEqual(scheduler.removedDeliveredIdentifiers, [identifier, identifier])
    }

    func testRestTimerNotificationServiceHonorsDisabledAndDeniedStates() async throws {
        let scheduler = FakeRestTimerNotificationScheduler(authorizationState: .authorized)
        let userDefaults = try makeEphemeralUserDefaults()
        let service = RestTimerNotificationService(
            scheduler: scheduler,
            userDefaults: userDefaults
        )
        let workoutID = UUID()
        let now = Date(timeIntervalSince1970: 1_000)

        service.setEnabledByPreference(false)
        let disabledResult = try await service.scheduleRestTimerNotification(
            workoutID: workoutID,
            workoutName: "Upper A",
            deadline: now.addingTimeInterval(90),
            now: now
        )

        service.setEnabledByPreference(true)
        scheduler.currentAuthorizationState = .denied
        let deniedResult = try await service.scheduleRestTimerNotification(
            workoutID: workoutID,
            workoutName: "Upper A",
            deadline: now.addingTimeInterval(90),
            now: now
        )

        XCTAssertEqual(disabledResult, .disabledByPreference)
        XCTAssertEqual(deniedResult, .denied)
        XCTAssertFalse(service.isEnabledByPreference())
        XCTAssertTrue(scheduler.addedRequests.isEmpty)
        XCTAssertEqual(scheduler.authorizationRequestCount, 0)
    }

    func testRestTimerNotificationServiceRequestsAuthorizationOnFirstLaunch() async throws {
        let scheduler = FakeRestTimerNotificationScheduler(authorizationState: .notDetermined)
        let userDefaults = try makeEphemeralUserDefaults()
        let service = RestTimerNotificationService(
            scheduler: scheduler,
            userDefaults: userDefaults
        )

        let isAuthorized = await service.requestAuthorizationOnFirstLaunchIfNeeded()

        XCTAssertTrue(isAuthorized)
        XCTAssertTrue(service.isEnabledByPreference())
        XCTAssertEqual(scheduler.authorizationRequestCount, 1)
        XCTAssertEqual(scheduler.currentAuthorizationState, .authorized)
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

    private func makeEphemeralUserDefaults() throws -> UserDefaults {
        let suiteName = "LiftBookTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}

private final class FakeRestTimerNotificationScheduler: RestTimerNotificationScheduling {
    var currentAuthorizationState: RestTimerNotificationAuthorizationState
    var authorizationRequestCount = 0
    var authorizationRequestResult = true
    var addedRequests: [RestTimerNotificationRequest] = []
    var removedPendingIdentifiers: [String] = []
    var removedDeliveredIdentifiers: [String] = []
    var restTimerIdentifiers: [String] = []

    init(authorizationState: RestTimerNotificationAuthorizationState) {
        self.currentAuthorizationState = authorizationState
    }

    func authorizationState() async -> RestTimerNotificationAuthorizationState {
        currentAuthorizationState
    }

    func requestAuthorization() async throws -> Bool {
        authorizationRequestCount += 1
        currentAuthorizationState = authorizationRequestResult ? .authorized : .denied
        return authorizationRequestResult
    }

    func add(_ request: RestTimerNotificationRequest) async throws {
        addedRequests.append(request)
    }

    func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        removedPendingIdentifiers.append(contentsOf: identifiers)
    }

    func removeDeliveredNotifications(withIdentifiers identifiers: [String]) {
        removedDeliveredIdentifiers.append(contentsOf: identifiers)
    }

    func restTimerNotificationIdentifiers(matchingPrefix prefix: String) async -> [String] {
        restTimerIdentifiers.filter { $0.hasPrefix(prefix) }
    }
}
