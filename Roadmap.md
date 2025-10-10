# 🗺️ LiftBook - Roadmap Complète

## **📊 Vue d'Ensemble**

| Phase | Durée | Objectif | Priorité |
|-------|-------|----------|----------|
| **Phase 0** | 1-2h | Infrastructure & Setup | 🔴 Critique |
| **Phase 1** | 10-12h | MVP Fonctionnel | 🔴 Critique |
| **Phase 2** | 8-10h | Features Essentielles | 🟡 Important |
| **Phase 3** | 10-15h | Polish & UX | 🟢 Nice to Have |
| **Phase 4** | 15-20h | Advanced Features | 🔵 Future |
| **Phase 5** | 20-30h | Apple Watch | 🔵 Future |

**Total estimé : 64-89 heures de dev**

---

## **Phase 0 : Infrastructure & Setup** 🏗️
**Durée : 1-2 heures | Priorité : 🔴 CRITIQUE**

### **Objectif**
Préparer l'architecture pour le futur (watchOS, HealthKit, sync)

### **Tasks**

- [ ] **Setup App Groups** (30 min)
  - Configurer dans Xcode (`group.com.dinoboros.LiftBook`)
  - Tester le partage de données
  
- [ ] **Mettre à jour LiftBookApp.swift** (15 min)
  - Configurer `ModelContainer` avec App Group
  - Ajouter iCloud sync (optionnel)
  
- [ ] **Créer AppState.swift** (15 min)
  ```swift
  Core/Services/AppState.swift
  ```
  
- [ ] **Créer UserPreferences.swift** (30 min)
  ```swift
  Core/Preferences/UserPreferences.swift
  - App Group support
  - kg/lbs, rest timer, haptic feedback
  ```
  
- [ ] **Mettre à jour les Modèles** (30 min)
  - Ajouter champs HealthKit à `Workout.swift`
  - Compléter `Exercise.swift` (force, level, mechanic)
  - Finaliser `ExerciseSet.swift`

### **✅ Deliverable**
Architecture solide prête pour watchOS + HealthKit

---

## **Phase 1 : MVP Fonctionnel** 🚀
**Durée : 10-12 heures | Priorité : 🔴 CRITIQUE**

### **Objectif**
App utilisable pour logger un workout de A à Z

### **1.1 Onboarding (2h)**

- [ ] **OnboardingView.swift** (1.5h)
  - Écran de chargement avec progress bar
  - Charger `exercises.json` (873 exercices)
  - Sauvegarder dans SwiftData
  - Animations smooth
  
- [ ] **ExerciseStore.swift** (30 min)
  - Service pour gérer les exercices
  - Méthodes de recherche et filtrage

**Deliverable :** Premier lancement qui charge les exercices

---

### **1.2 Browse Exercises (3h)**

- [ ] **ExerciseBrowserView.swift** (2h)
  - Liste des exercices
  - Barre de recherche
  - Filtres par catégorie (strength, cardio, etc.)
  - Filtres par muscle (chest, back, etc.)
  
- [ ] **ExerciseDetailView.swift** (1h)
  - Détails complets de l'exercice
  - Instructions step-by-step
  - Muscles ciblés
  - Équipement requis
  - Bouton "Add to Workout"

**Deliverable :** Parcourir et découvrir les exercices

---

### **1.3 Active Workout (5-6h)**

- [ ] **WorkoutSessionView.swift** (2.5h)
  - Header avec nom + timer live
  - Stats en temps réel (sets, volume, durée)
  - Liste des exercices ajoutés
  - Bouton "Add Exercise"
  - Bouton "Finish Workout"
  
- [ ] **AddSetSheet.swift** (1.5h)
  - Input poids (avec conversion kg/lbs)
  - Input reps
  - Input temps de repos
  - Bouton "Save Set"
  - Voir les derniers sets pour cet exercice
  
- [ ] **RestTimerView.swift** (1h)
  - Compte à rebours
  - Progress circle
  - Notification/vibration à la fin
  - Bouton skip/pause
  
- [ ] **ExercisePickerSheet.swift** (1h)
  - Recherche d'exercice
  - Catégories
  - Sélection rapide

**Deliverable :** Logger un workout complet

---

### **1.4 Basic History (1-2h)**

- [ ] **WorkoutHistoryView.swift** (1h)
  - Liste des workouts complétés
  - Tri par date
  - Stats de base (durée, volume, sets)
  
- [ ] **WorkoutDetailView.swift** (1h)
  - Détails d'un workout passé
  - Liste des exercices et sets
  - Notes

**Deliverable :** Voir l'historique des workouts

---

### **🎯 Milestone 1 : MVP Live**
**À ce stade, tu as une app fonctionnelle que tu peux utiliser quotidiennement !**

---

## **Phase 2 : Features Essentielles** ⭐
**Durée : 8-10 heures | Priorité : 🟡 IMPORTANT**

### **2.1 Custom Exercises (2h)**

- [ ] **CreateExerciseView.swift** (1.5h)
  - Formulaire complet
  - Validation
  - Sauvegarde avec `isCustom = true`
  
- [ ] **EditExerciseView.swift** (30 min)
  - Modifier un exercice custom
  - Impossible de modifier les exercices du JSON

**Deliverable :** Créer ses propres exercices

---

### **2.2 Workout Templates (2-3h)**

- [ ] **Modèle WorkoutTemplate** (30 min)
  ```swift
  @Model
  final class WorkoutTemplate {
      var id: UUID
      var name: String
      var exercises: [TemplateExercise]
  }
  ```
  
- [ ] **TemplatesView.swift** (1h)
  - Liste des templates
  - Créer un template depuis un workout
  - Démarrer un workout depuis un template
  
- [ ] **CreateTemplateView.swift** (1h)
  - Créer un template from scratch
  - Ajouter exercices + sets suggérés

**Deliverable :** Répéter les mêmes workouts facilement

---

### **2.3 Enhanced Stats (2-3h)**

- [ ] **StatsView.swift** (1.5h)
  - Volume par semaine/mois
  - Nombre de workouts
  - Temps total d'entraînement
  - Exercices les plus faits
  
- [ ] **ExerciseProgressView.swift** (1h)
  - Graphique de progression pour un exercice
  - Max weight over time
  - Volume over time
  - Personal Records (PRs)
  
- [ ] **PRTracker** (30 min)
  - Détecter les nouveaux PRs
  - Badge "New PR!" pendant le workout

**Deliverable :** Voir sa progression

---

### **2.4 Settings Screen (1-2h)**

- [ ] **SettingsView.swift** (1h)
  - Unités (kg/lbs)
  - Rest timer defaults
  - Haptic feedback
  - App version, about
  
- [ ] **DataManagementView.swift** (1h)
  - Export data (JSON)
  - Import data
  - Clear all data
  - Reset to default exercises

**Deliverable :** Personnaliser l'app

---

### **🎯 Milestone 2 : App Complète**
**À ce stade, l'app est prête pour TestFlight / App Store !**

---

## **Phase 3 : Polish & UX** ✨
**Durée : 10-15 heures | Priorité : 🟢 NICE TO HAVE**

### **3.1 UI/UX Improvements (3-4h)**

- [ ] **Animations & Transitions** (2h)
  - Smooth navigation
  - Haptic feedback
  - Loading states élégants
  
- [ ] **Dark Mode Polish** (1h)
  - Tester tous les écrans
  - Ajuster les couleurs
  
- [ ] **iPad Support** (1h)
  - Responsive layout
  - Split view
  - Keyboard shortcuts

---

### **3.2 Advanced Filtering (2h)**

- [ ] **Smart Filters**
  - Filtrer par équipement disponible
  - Filtrer par difficulté
  - Filtrer par muscle group
  - Suggestions basées sur l'historique

---

### **3.3 Notes & Media (3-4h)**

- [ ] **Notes System**
  - Notes par set
  - Notes par workout
  - Notes par exercice (form tips)
  
- [ ] **Photo/Video Support** (optionnel)
  - Photos de progression
  - Videos de form check
  - Attachés aux workouts

---

### **3.4 Social Features (Light) (2-3h)**

- [ ] **Share Workouts**
  - Partager un workout terminé
  - Belle image générée
  - Stats visuelles
  
- [ ] **Export/Import Templates**
  - Partager des templates entre users
  - QR codes

---

### **🎯 Milestone 3 : App Store Ready**
**Prête pour un lancement public !**

---

## **Phase 4 : Advanced Features** 🚀
**Durée : 15-20 heures | Priorité : 🔵 FUTURE**

### **4.1 Analytics & Insights (4-5h)**

- [ ] **Body Part Frequency**
  - Quels muscles travaillés cette semaine
  - Alertes de déséquilibre (trop de push, pas assez de pull)
  
- [ ] **Recovery Tracker**
  - Temps depuis dernier workout par muscle
  - Suggestions basées sur recovery
  
- [ ] **Volume Tracker**
  - Volume par muscle group
  - Trends over time
  - Recommendations

---

### **4.2 Program Builder (5-6h)**

- [ ] **Week Programs**
  - Créer des programmes de plusieurs semaines
  - PPL, Upper/Lower, Full Body, etc.
  - Progression automatique
  
- [ ] **Periodization**
  - Phases (strength, hypertrophy, deload)
  - Auto-adjust weights

---

### **4.3 Widgets & Live Activities (3-4h)**

- [ ] **Home Screen Widgets**
  - Next workout
  - Stats du mois
  - Streak
  
- [ ] **Lock Screen Widgets**
  - Quick stats
  
- [ ] **Live Activities**
  - Workout en cours sur Dynamic Island
  - Rest timer countdown

---

### **4.4 AI Features (3-5h)**

- [ ] **Workout Suggestions**
  - Basé sur l'historique
  - Recommandations d'exercices
  
- [ ] **Form Tips**
  - AI-generated tips basés sur l'exercice

---

## **Phase 5 : Apple Watch App** ⌚
**Durée : 20-30 heures | Priorité : 🔵 FUTURE**

### **5.1 Watch App Setup (2-3h)**

- [ ] **watchOS Target**
  - Créer la target
  - Configurer App Groups
  - Shared Core framework
  
- [ ] **Basic Navigation**
  - Tab view
  - Complications

---

### **5.2 Core Watch Features (8-10h)**

- [ ] **Quick Start Workout** (2h)
  - Liste des templates
  - Démarrer workout d'un tap
  
- [ ] **Log Sets** (3-4h)
  - Input optimisé Watch (Digital Crown)
  - Voice input pour reps/poids
  - Haptic feedback
  
- [ ] **Rest Timer** (2h)
  - Compte à rebours full screen
  - Vibration
  - Auto-start next set
  
- [ ] **Live Metrics** (1-2h)
  - Sets complétés
  - Volume total
  - Durée

---

### **5.3 HealthKit Integration (6-8h)**

- [ ] **Workout Sessions** (3h)
  - Démarrer HKWorkoutSession
  - Track heart rate live
  - Calories burned
  
- [ ] **Health Data Sync** (2h)
  - Sauvegarder workouts dans Apple Health
  - Active energy
  - Exercise minutes
  
- [ ] **Heart Rate Zones** (2-3h)
  - Afficher zone actuelle
  - Stats post-workout
  - Recommendations

---

### **5.4 Standalone Mode (4-6h)**

- [ ] **Offline Capability**
  - SwiftData local sur Watch
  - Sync quand iPhone à portée
  
- [ ] **Connectivity**
  - WatchConnectivity framework
  - Background sync

---

### **🎯 Milestone 4 : Ecosystem Complet**
**App iPhone + Watch parfaitement intégrées !**

---

## **📅 Timeline Suggérée**

### **Sprint 1 (Semaine 1) - Foundation**
- Phase 0 (Infrastructure)
- Phase 1.1-1.2 (Onboarding + Browse)
- **Goal:** Voir les exercices

### **Sprint 2 (Semaine 2) - Core Workout**
- Phase 1.3 (Active Workout)
- **Goal:** Logger son premier workout

### **Sprint 3 (Semaine 3) - MVP Complete**
- Phase 1.4 (History)
- Phase 2.1-2.2 (Custom Exercises + Templates)
- **Goal:** App utilisable quotidiennement

### **Sprint 4 (Semaine 4) - Polish**
- Phase 2.3-2.4 (Stats + Settings)
- Phase 3.1 (UI Polish)
- **Goal:** TestFlight Beta

### **Sprint 5-6 (Semaines 5-6) - Advanced**
- Phase 3.2-3.4 (Advanced features)
- Phase 4 (Analytics)
- **Goal:** App Store Launch

### **Sprint 7+ (Future)**
- Phase 5 (Apple Watch)
- **Goal:** Ecosystem complet

---

## **🎯 Quick Wins (Priorités Immédiates)**

### **Cette semaine :**
1. ✅ Infrastructure (App Groups, ModelContainer)
2. ✅ AppState + UserPreferences
3. ✅ OnboardingView
4. ✅ ExerciseBrowserView

### **Semaine prochaine :**
5. ✅ WorkoutSessionView
6. ✅ AddSetSheet
7. ✅ RestTimer

### **Dans 2 semaines :**
8. ✅ WorkoutHistoryView
9. ✅ Custom Exercises
10. ✅ TestFlight Beta

---

## **📊 Metrics de Succès**

| Milestone | Metric |
|-----------|--------|
| **MVP** | Pouvoir logger 1 workout complet |
| **Phase 2** | 10+ workouts loggés par toi |
| **TestFlight** | 5+ beta testers actifs |
| **Launch** | 100+ downloads semaine 1 |
| **Watch** | 50% des users avec Watch l'utilisent |

---

## **🛠️ Stack Technique - Résumé**

iOS App
├── SwiftUI (UI)
├── SwiftData (Persistence)
├── App Groups (iPhone ↔️ Watch)
├── UserDefaults (Settings)
└── HealthKit (Future - Watch)
watchOS App (Future)
├── SwiftUI
├── SwiftData (Shared)
├── HealthKit
└── WatchConnectivity

---

## 💡 Recommandations

### Focus MVP D'abord
Ne pas se disperser. Phase 1 = 100% du focus.

### Tester Tôt
Utilise l'app toi-même dès Phase 1.3. Tu trouveras les bugs et UX issues.

### TestFlight Rapide
Dès Phase 2 complétée, ouvre à des beta testers.

### Watch = Version 2.0
Lance l'app iPhone d'abord. Watch = grosse feature update.

---

## 📝 Notes

- Dernière mise à jour : 5 octobre 2025
- Base de données : 873 exercices (yuhonas/free-exercise-db)
- Architecture prête pour watchOS depuis le début
- SwiftData + App Groups configurés

---

**Status actuel : Phase 0 en cours** 🚀