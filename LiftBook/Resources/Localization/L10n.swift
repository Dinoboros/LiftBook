//
//  L10n.swift
//  LiftBook
//
//  Created by Méryl VALIER on 20/10/2025.
//

import SwiftUI

enum L10n {
    enum App {
       static let tabHomeTitle: LocalizedStringKey = "tab.home.title"
       static let tabWorkoutTitle: LocalizedStringKey = "tab.workout.title"
       static let tabProfileTitle: LocalizedStringKey = "tab.profile.title"
     }
    
    enum Home {
        static let recentWorkoutsTitle: LocalizedStringKey = "home.recent.workouts.title"
    }
    
    enum Workout {
        enum WorkoutCreation {
            static let addExerciseButtonTitle: LocalizedStringKey = "workout.creation.add.exercise.button.title"
            static let exercisesSectionTitle: LocalizedStringKey = "workout.creation.exercise.title"
            static let templateNamePlaceholder: LocalizedStringKey = "workout.creation.templateName.placeholder"
            static let newWorkoutTitle: LocalizedStringKey = "workout.creation.navigation.title"
        }

        static let startAnEmptyWorkoutButtonTitle: LocalizedStringKey = "workout.start.an.empty.workout.button.title"
        static let createANewTemplateButtonTitle: LocalizedStringKey = "workout.create.a.new.template.button.title"
        static let myWorkoutsTitle: LocalizedStringKey = "workout.my.workouts.title"
        static let startWorkoutButtonTitle: LocalizedStringKey = "workout.start.workout.button.title"
    }
    
    enum ExercisePicker {
        static let createExerciseButtonTitle: LocalizedStringKey = "exercise.create.button.title"
        static let exercisesListTitle: LocalizedStringKey = "exercise.list.title"
        static let searchExercisesPlaceholder: LocalizedStringKey = "exercise.search.placeholder"
        static let noExercisesTitle: LocalizedStringKey = "exercise.no.exercises.title"
        static let noExercisesDescription: LocalizedStringKey = "exercise.no.exercises.description"
        static let allEquipmentButtonTitle: LocalizedStringKey = "exercise.all.equipment.button.title"
    }
    
    enum Profile {
        static let settingsButtonTitle: LocalizedStringKey = "profile.settings.button.title"
        static let editProfileButtonTitle: LocalizedStringKey = "profile.edit.profile.button.title"
        static let exerciseListButtonTitle: LocalizedStringKey = "profile.exercise.list.button.title"
    }
    
    enum Onboarding { 
        static let preparingExercisesLibraryTitle: LocalizedStringKey = "onboarding.preparing.exercises.library.title"
        static let preparingExercisesLibraryRetryButtonTitle: LocalizedStringKey = "onboarding.preparing.exercises.library.retry.button.title"
    }
}
