//
//  MockData.swift
//  LiftBook
//
//  Created by LiftBook Team on 11/10/2025.
//

import Foundation

struct MockData {

    // MARK: - Mock Exercises

    static let mockExercises: [Exercise] = [
        Exercise(
            id: "bench-press",
            name: "Bench Press",
            equipment: "Barbell",
            primaryMuscles: ["Chest"],
            secondaryMuscles: ["Triceps", "Shoulders"],
            instructions: ["Lie on bench", "Grip barbell", "Lower to chest", "Press up"],
            category: "Strength"
        ),
        Exercise(
            id: "squat",
            name: "Squat",
            equipment: "Barbell",
            primaryMuscles: ["Quadriceps"],
            secondaryMuscles: ["Glutes", "Hamstrings"],
            instructions: ["Stand with feet shoulder width", "Lower with control", "Drive through heels"],
            category: "Strength"
        ),
        Exercise(
            id: "deadlift",
            name: "Deadlift",
            equipment: "Barbell",
            primaryMuscles: ["Hamstrings"],
            secondaryMuscles: ["Glutes", "Lower Back"],
            instructions: ["Stand with feet hip width", "Grip barbell", "Lift with straight back"],
            category: "Strength"
        ),
        Exercise(
            id: "overhead-press",
            name: "Overhead Press",
            equipment: "Barbell",
            primaryMuscles: ["Shoulders"],
            secondaryMuscles: ["Triceps"],
            instructions: ["Stand with barbell at chest", "Press overhead", "Lower with control"],
            category: "Strength"
        ),
        Exercise(
            id: "pull-up",
            name: "Pull-up",
            equipment: "Bodyweight",
            primaryMuscles: ["Lats"],
            secondaryMuscles: ["Biceps"],
            instructions: ["Hang from bar", "Pull body up", "Lower with control"],
            category: "Strength"
        ),
        Exercise(
            id: "push-up",
            name: "Push-up",
            equipment: "Bodyweight",
            primaryMuscles: ["Chest"],
            secondaryMuscles: ["Triceps", "Shoulders"],
            instructions: ["Start in plank position", "Lower chest to ground", "Push back up"],
            category: "Strength"
        )
    ]

    // MARK: - Mock Exercise Sets

    static let mockExerciseSets: [ExerciseSet] = [
        ExerciseSet(exercise: mockExercises.first { $0.id == "bench-press" }!, reps: 10, weight: 75, rest: 180),
        ExerciseSet(exercise: mockExercises.first { $0.id == "squat" }!, reps: 8, weight: 90, rest: 240)
    ]

    // MARK: - Mock Workout Exercises

    static let mockWorkoutExercises: [WorkoutExercise] = [
        createMockBenchPressWorkoutExercise(),
        createMockSquatWorkoutExercise()
    ]

    private static func createMockBenchPressWorkoutExercise() -> WorkoutExercise {
        let workoutExercise = WorkoutExercise(exercise: mockExercises.first { $0.id == "bench-press" }!, order: 0)

        // Add some sets for bench press
        let set1 = ExerciseSet(exercise: mockExercises.first { $0.id == "bench-press" }!, reps: 10, weight: 75, rest: 180)
        let set2 = ExerciseSet(exercise: mockExercises.first { $0.id == "bench-press" }!, reps: 8, weight: 80, rest: 180)
        let set3 = ExerciseSet(exercise: mockExercises.first { $0.id == "bench-press" }!, reps: 6, weight: 85, rest: 180)

        workoutExercise.addSet(set1)
        workoutExercise.addSet(set2)
        workoutExercise.addSet(set3)

        return workoutExercise
    }

    private static func createMockSquatWorkoutExercise() -> WorkoutExercise {
        let workoutExercise = WorkoutExercise(exercise: mockExercises.first { $0.id == "squat" }!, order: 1)

        // Add some sets for squat
        let set1 = ExerciseSet(exercise: mockExercises.first { $0.id == "squat" }!, reps: 8, weight: 90, rest: 240)
        let set2 = ExerciseSet(exercise: mockExercises.first { $0.id == "squat" }!, reps: 6, weight: 95, rest: 240)
        let set3 = ExerciseSet(exercise: mockExercises.first { $0.id == "squat" }!, reps: 4, weight: 100, rest: 240)

        workoutExercise.addSet(set1)
        workoutExercise.addSet(set2)
        workoutExercise.addSet(set3)

        return workoutExercise
    }

    // MARK: - Mock Workouts

    static let mockWorkouts: [Workout] = [
        createUpperBodyWorkout(),
        createLegWorkout(),
        createFullBodyWorkout(),
        createPushWorkout(),
        createPullDay(),
        createArmDay(),
        createChestFocus(),
        createBackAndBiceps(),
        createShoulderWorkout(),
        createCoreWorkout(),
        createCardioConditioning(),
        createPowerlifting(),
        createHypertrophy(),
        createFunctionalTraining()
    ]

    // MARK: - Workout Creation Functions

    private static func createUpperBodyWorkout() -> Workout {
        let workout = Workout(name: "Upper Body Strength")
        workout.startedAt = Date().addingTimeInterval(-86400) // Yesterday

        // Bench Press sets
        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 8, weight: 80, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 8, weight: 80, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 6, weight: 85, rest: 180))

        // Pull-ups sets
        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 10, weight: 0, rest: 120))
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 8, weight: 0, rest: 120))

        // Complete some sets
        workout.exerciseSets[0].completedAt = Date()
        workout.exerciseSets[1].completedAt = Date()
        workout.exerciseSets[3].completedAt = Date()

        workout.complete(withNotes: "Great pump today!")
        return workout
    }

    private static func createLegWorkout() -> Workout {
        let workout = Workout(name: "Leg Day")
        workout.startedAt = Date().addingTimeInterval(-172800) // 2 days ago

        // Squat sets
        let squat = mockExercises.first { $0.id == "squat" }!
        workout.addSet(ExerciseSet(exercise: squat, reps: 5, weight: 100, rest: 240))
        workout.addSet(ExerciseSet(exercise: squat, reps: 5, weight: 100, rest: 240))
        workout.addSet(ExerciseSet(exercise: squat, reps: 5, weight: 100, rest: 240))

        // Deadlift sets
        let deadlift = mockExercises.first { $0.id == "deadlift" }!
        workout.addSet(ExerciseSet(exercise: deadlift, reps: 5, weight: 120, rest: 300))
        workout.addSet(ExerciseSet(exercise: deadlift, reps: 3, weight: 130, rest: 300))

        // Complete all sets
        workout.exerciseSets.forEach { $0.completedAt = Date() }

        workout.complete(withNotes: "Heavy day, feeling strong!")
        return workout
    }

    private static func createFullBodyWorkout() -> Workout {
        let workout = Workout(name: "Full Body Circuit")
        workout.startedAt = Date().addingTimeInterval(-259200) // 3 days ago

        // Push-ups
        let pushUps = mockExercises.first { $0.id == "push-up" }!
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 15, weight: 0, rest: 60))
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 12, weight: 0, rest: 60))
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 10, weight: 0, rest: 60))

        // Overhead Press
        let overheadPress = mockExercises.first { $0.id == "overhead-press" }!
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 10, weight: 40, rest: 90))

        // Complete all sets
        workout.exerciseSets.forEach { $0.completedAt = Date() }

        workout.complete(withNotes: "Circuit training - good cardio!")
        return workout
    }

    private static func createPushWorkout() -> Workout {
        let workout = Workout(name: "Push Focus")
        workout.startedAt = Date().addingTimeInterval(-345600) // 4 days ago

        // Bench Press
        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 10, weight: 70, rest: 180))

        // Push-ups
        let pushUps = mockExercises.first { $0.id == "push-up" }!
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 20, weight: 0, rest: 60))

        // Complete half the sets
        workout.exerciseSets[0].completedAt = Date()

        return workout
    }

    private static func createPullDay() -> Workout {
        let workout = Workout(name: "Pull Day")
        workout.startedAt = Date().addingTimeInterval(-432000) // 5 days ago

        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 12, weight: 0, rest: 120))
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 10, weight: 0, rest: 120))
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 8, weight: 0, rest: 120))

        let deadlift = mockExercises.first { $0.id == "deadlift" }!
        workout.addSet(ExerciseSet(exercise: deadlift, reps: 5, weight: 110, rest: 240))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Strong pulling session!")
        return workout
    }

    private static func createArmDay() -> Workout {
        let workout = Workout(name: "Arm Day")
        workout.startedAt = Date().addingTimeInterval(-518400) // 6 days ago

        // Bicep curls (using overhead press as proxy for arm exercises)
        let overheadPress = mockExercises.first { $0.id == "overhead-press" }!
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 12, weight: 30, rest: 90))
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 10, weight: 35, rest: 90))
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 8, weight: 40, rest: 90))

        // Tricep extensions (using bench press as proxy)
        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 15, weight: 50, rest: 60))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Arms are pumped!")
        return workout
    }

    private static func createChestFocus() -> Workout {
        let workout = Workout(name: "Chest Focus")
        workout.startedAt = Date().addingTimeInterval(-604800) // 7 days ago

        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 10, weight: 75, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 8, weight: 80, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 6, weight: 85, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 4, weight: 90, rest: 180))

        let pushUps = mockExercises.first { $0.id == "push-up" }!
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 20, weight: 0, rest: 60))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Maximum chest development!")
        return workout
    }

    private static func createBackAndBiceps() -> Workout {
        let workout = Workout(name: "Back & Biceps")
        workout.startedAt = Date().addingTimeInterval(-691200) // 8 days ago

        let deadlift = mockExercises.first { $0.id == "deadlift" }!
        workout.addSet(ExerciseSet(exercise: deadlift, reps: 8, weight: 100, rest: 240))
        workout.addSet(ExerciseSet(exercise: deadlift, reps: 6, weight: 110, rest: 240))

        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 12, weight: 0, rest: 120))
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 10, weight: 0, rest: 120))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Wide back, peaked biceps!")
        return workout
    }

    private static func createShoulderWorkout() -> Workout {
        let workout = Workout(name: "Shoulder Day")
        workout.startedAt = Date().addingTimeInterval(-777600) // 9 days ago

        let overheadPress = mockExercises.first { $0.id == "overhead-press" }!
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 10, weight: 45, rest: 120))
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 8, weight: 50, rest: 120))
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 6, weight: 55, rest: 120))

        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 12, weight: 60, rest: 90))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Shoulders feeling capped!")
        return workout
    }

    private static func createCoreWorkout() -> Workout {
        let workout = Workout(name: "Core Blast")
        workout.startedAt = Date().addingTimeInterval(-864000) // 10 days ago

        // Using bodyweight exercises for core
        let pushUps = mockExercises.first { $0.id == "push-up" }!
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 25, weight: 0, rest: 45))
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 20, weight: 0, rest: 45))
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 15, weight: 0, rest: 45))

        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 15, weight: 0, rest: 60))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Core is on fire!")
        return workout
    }

    private static func createCardioConditioning() -> Workout {
        let workout = Workout(name: "Cardio Conditioning")
        workout.startedAt = Date().addingTimeInterval(-950400) // 11 days ago

        let pushUps = mockExercises.first { $0.id == "push-up" }!
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 30, weight: 0, rest: 30))
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 25, weight: 0, rest: 30))
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 20, weight: 0, rest: 30))

        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 20, weight: 0, rest: 45))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "High intensity conditioning!")
        return workout
    }

    private static func createPowerlifting() -> Workout {
        let workout = Workout(name: "Powerlifting Session")
        workout.startedAt = Date().addingTimeInterval(-1036800) // 12 days ago

        let squat = mockExercises.first { $0.id == "squat" }!
        workout.addSet(ExerciseSet(exercise: squat, reps: 3, weight: 120, rest: 300))
        workout.addSet(ExerciseSet(exercise: squat, reps: 3, weight: 120, rest: 300))
        workout.addSet(ExerciseSet(exercise: squat, reps: 3, weight: 120, rest: 300))

        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 3, weight: 100, rest: 300))

        let deadlift = mockExercises.first { $0.id == "deadlift" }!
        workout.addSet(ExerciseSet(exercise: deadlift, reps: 3, weight: 140, rest: 300))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Raw power session!")
        return workout
    }

    private static func createHypertrophy() -> Workout {
        let workout = Workout(name: "Hypertrophy Training")
        workout.startedAt = Date().addingTimeInterval(-1123200) // 13 days ago

        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 12, weight: 65, rest: 90))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 10, weight: 70, rest: 90))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 8, weight: 75, rest: 90))

        let squat = mockExercises.first { $0.id == "squat" }!
        workout.addSet(ExerciseSet(exercise: squat, reps: 12, weight: 80, rest: 120))
        workout.addSet(ExerciseSet(exercise: squat, reps: 10, weight: 85, rest: 120))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Muscle building focus!")
        return workout
    }

    private static func createFunctionalTraining() -> Workout {
        let workout = Workout(name: "Functional Training")
        workout.startedAt = Date().addingTimeInterval(-1209600) // 14 days ago

        let pushUps = mockExercises.first { $0.id == "push-up" }!
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 15, weight: 0, rest: 60))
        workout.addSet(ExerciseSet(exercise: pushUps, reps: 12, weight: 0, rest: 60))

        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 10, weight: 0, rest: 60))

        let squat = mockExercises.first { $0.id == "squat" }!
        workout.addSet(ExerciseSet(exercise: squat, reps: 20, weight: 0, rest: 90))

        workout.exerciseSets.forEach { $0.completedAt = Date() }
        workout.complete(withNotes: "Movement quality focus!")
        return workout
    }

    // MARK: - Helper Functions

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func formatDuration(_ duration: TimeInterval?) -> String {
        guard let duration = duration else { return "In progress" }

        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }

    // MARK: - Saved Routine Workouts

    static let savedRoutineWorkouts: [Workout] = [
        createPushPullLegs(),
        createUpperLowerSplit(),
        createFullBodyRoutine()
    ]

    private static func createPushPullLegs() -> Workout {
        let workout = Workout(name: "Push/Pull/Legs")
        // Pas de date spécifique - c'est une routine sauvegardée

        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 8, weight: 75, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 8, weight: 75, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 6, weight: 80, rest: 180))

        let squat = mockExercises.first { $0.id == "squat" }!
        workout.addSet(ExerciseSet(exercise: squat, reps: 5, weight: 90, rest: 240))
        workout.addSet(ExerciseSet(exercise: squat, reps: 5, weight: 90, rest: 240))
        workout.addSet(ExerciseSet(exercise: squat, reps: 5, weight: 90, rest: 240))

        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 10, weight: 0, rest: 120))
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 8, weight: 0, rest: 120))
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 6, weight: 0, rest: 120))

        return workout
    }

    private static func createUpperLowerSplit() -> Workout {
        let workout = Workout(name: "Upper/Lower Split")
        // Pas de date spécifique - c'est une routine sauvegardée

        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 10, weight: 70, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 8, weight: 75, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 6, weight: 80, rest: 180))

        let overheadPress = mockExercises.first { $0.id == "overhead-press" }!
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 10, weight: 45, rest: 120))
        workout.addSet(ExerciseSet(exercise: overheadPress, reps: 8, weight: 50, rest: 120))

        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 12, weight: 0, rest: 120))
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 10, weight: 0, rest: 120))

        return workout
    }

    private static func createFullBodyRoutine() -> Workout {
        let workout = Workout(name: "Full Body Routine")
        // Pas de date spécifique - c'est une routine sauvegardée

        let squat = mockExercises.first { $0.id == "squat" }!
        workout.addSet(ExerciseSet(exercise: squat, reps: 8, weight: 80, rest: 180))
        workout.addSet(ExerciseSet(exercise: squat, reps: 8, weight: 80, rest: 180))
        workout.addSet(ExerciseSet(exercise: squat, reps: 6, weight: 85, rest: 180))

        let benchPress = mockExercises.first { $0.id == "bench-press" }!
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 10, weight: 65, rest: 180))
        workout.addSet(ExerciseSet(exercise: benchPress, reps: 8, weight: 70, rest: 180))

        let deadlift = mockExercises.first { $0.id == "deadlift" }!
        workout.addSet(ExerciseSet(exercise: deadlift, reps: 5, weight: 100, rest: 240))

        let pullUps = mockExercises.first { $0.id == "pull-up" }!
        workout.addSet(ExerciseSet(exercise: pullUps, reps: 10, weight: 0, rest: 120))

        return workout
    }
}
