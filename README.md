# LiftBook

LiftBook est une application iOS de suivi de musculation. Elle permet de préparer des routines, lancer une séance depuis une routine ou une séance vide, enregistrer les séries réalisées et conserver un historique local des entraînements.

Le projet est construit en SwiftUI avec SwiftData. Les données restent stockées localement sur l'appareil.

## Fonctionnalités

- Onboarding avec import local d'une bibliothèque d'exercices.
- Création, modification, duplication et suppression de routines.
- Démarrage d'une séance vide ou depuis une routine existante.
- Suivi d'une séance active avec exercices, séries, répétitions et charges.
- Timer de repos avec notifications locales.
- Historique des séances terminées avec détail des exercices et séries validées.
- Bibliothèque d'exercices filtrable, consultable et extensible avec des exercices personnalisés.
- Préférence d'unité de charge en kilogrammes ou livres.
- Écran de réglages avec accès à la bibliothèque, notifications et informations d'app.

## Stack technique

- Swift
- SwiftUI
- SwiftData
- UserNotifications
- XCTest
- Xcode 26.4
- iOS 26.0+

## Structure du projet

```text
LiftBook/
├── App/                    # Point d'entrée, lancement, splash et environnement
├── Data/
│   ├── Persistence/        # Modèles SwiftData et configuration du ModelContainer
│   └── Seed/               # Import de la bibliothèque d'exercices embarquée
├── Drafts/                 # États intermédiaires pour les formulaires
├── Features/
│   ├── ActiveWorkout/      # Suivi d'une séance en cours
│   ├── Debug/              # Outils de debug en configuration DEBUG
│   ├── Exercises/          # Bibliothèque et exercices personnalisés
│   ├── Home/               # Accueil, routines et historique
│   ├── Onboarding/         # Premier lancement et préparation des données
│   ├── Routines/           # Création et édition de routines
│   └── Settings/           # Préférences utilisateur
├── Services/               # Logique métier applicative
├── DesignSystem/           # Composants et tokens UI réutilisables
└── Resources/              # Ressources embarquées, dont exercises.json
```

Les tests unitaires se trouvent dans `LiftBookTests/`.

## Données locales

LiftBook utilise SwiftData pour stocker :

- les exercices embarqués et personnalisés ;
- les routines ;
- les séances en cours ;
- l'historique des séances terminées ;
- les séries, répétitions et charges associées.

## Licence

À définir.
