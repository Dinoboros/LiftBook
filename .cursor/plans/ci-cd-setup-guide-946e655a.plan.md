<!-- 946e655a-6345-4524-a0b5-e7761838993d e517be49-0f5d-48a9-959f-a118e9ed3862 -->
# CI/CD Setup - GitHub Actions pour LiftBook

## Approche Progressive (Learning Path)

Cette roadmap te permettra d'apprendre la CI/CD en construisant une pipeline complète étape par étape.

---

## Étape 1 : Initialiser le Repo GitHub

**Objectif : Avoir un repo GitHub propre avec les bonnes pratiques**

### Actions

1. Créer le repo GitHub `LiftBook` (privé ou public selon préférence)
2. Créer `.gitignore` adapté pour iOS/Swift

                                                                                                - Exclure `UserInterfaceState.xcuserstate`, `.DS_Store`, `xcuserdata/`, etc.

3. Créer un `README.md` descriptif avec badges CI (à ajouter après)
4. Faire le premier commit et push

### Fichiers à créer

- `.gitignore` - Template iOS/Xcode
- `README.md` - Description du projet

**Learning point** : Bonnes pratiques Git pour projets iOS

---

## Étape 2 : Linting (Premier Workflow CI)

**Objectif : Apprendre les bases de GitHub Actions avec SwiftLint**

### Actions

1. Créer `.github/workflows/lint.yml`
2. Configurer SwiftLint (installation + run sur chaque PR/push)
3. Créer `.swiftlint.yml` avec règles de base
4. Tester le workflow en créant une PR

### Workflow `lint.yml`

```yaml
name: SwiftLint

on:
  pull_request:
  push:
    branches: [main]

jobs:
  swiftlint:
    runs-on: macos-latest
    steps:
                                                                                 - uses: actions/checkout@v4
                                                                                 - name: SwiftLint
        run: |
          brew install swiftlint
          swiftlint --strict
```

### Fichiers à créer

- `.github/workflows/lint.yml`
- `.swiftlint.yml` - Règles de style

**Learning points** :

- Structure des workflows GitHub Actions
- Triggers (on push, pull_request)
- Jobs et steps
- Runners (macos-latest)

---

## Étape 3 : Tests Automatiques

**Objectif : Exécuter les tests unitaires automatiquement**

### Actions

1. Créer `.github/workflows/tests.yml`
2. Configurer xcodebuild pour run tests
3. Ajouter code coverage report
4. Ajouter badge de tests dans README

### Workflow `tests.yml`

```yaml
name: Tests

on:
  pull_request:
  push:
    branches: [main]

jobs:
  test:
    runs-on: macos-latest
    steps:
                                                                                 - uses: actions/checkout@v4
      
                                                                                 - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode_15.0.app
      
                                                                                 - name: Run Tests
        run: |
          xcodebuild test \
            -scheme LiftBook \
            -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' \
            -enableCodeCoverage YES
      
                                                                                 - name: Upload Coverage
        uses: codecov/codecov-action@v3
```

**Learning points** :

- Configuration Xcode dans CI
- Destinations de build (simulateurs)
- Code coverage

---

## Étape 4 : Build Validation

**Objectif : Valider que l'app build correctement**

### Actions

1. Créer `.github/workflows/build.yml`
2. Configurer build pour Debug et Release
3. Archiver l'app (sans signature pour l'instant)
4. Uploader les artifacts

### Workflow `build.yml`

```yaml
name: Build

on:
  pull_request:
  push:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest
    strategy:
      matrix:
        configuration: [Debug, Release]
    steps:
                                                                                 - uses: actions/checkout@v4
      
                                                                                 - name: Build
        run: |
          xcodebuild build \
            -scheme LiftBook \
            -configuration ${{ matrix.configuration }} \
            -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Learning points** :

- Matrix builds (tester plusieurs configs)
- Build configurations (Debug/Release)
- Artifacts

---

## Étape 5 : Secrets & Code Signing

**Objectif : Configurer la signature de code pour distribution**

### Actions

1. Créer certificat de distribution dans Apple Developer
2. Créer provisioning profiles (TestFlight + App Store)
3. Encoder en base64 et ajouter aux GitHub Secrets
4. Installer certificat/profile dans le workflow

### Secrets à configurer dans GitHub

- `BUILD_CERTIFICATE_BASE64` - Certificat .p12 encodé
- `P12_PASSWORD` - Mot de passe du certificat
- `BUILD_PROVISION_PROFILE_BASE64` - Provisioning profile
- `KEYCHAIN_PASSWORD` - Password temporaire keychain

### Script d'installation (dans workflow)

```yaml
- name: Install Apple Certificate
  env:
    BUILD_CERTIFICATE_BASE64: ${{ secrets.BUILD_CERTIFICATE_BASE64 }}
    P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
    KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
  run: |
    # Créer keychain temporaire
    security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
    
    # Importer certificat
    echo $BUILD_CERTIFICATE_BASE64 | base64 --decode > certificate.p12
    security import certificate.p12 -k build.keychain -P "$P12_PASSWORD" -T /usr/bin/codesign
    
    # Installer provisioning profile
    echo $BUILD_PROVISION_PROFILE_BASE64 | base64 --decode > profile.mobileprovision
    mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
    cp profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
```

**Learning points** :

- Code signing sur CI
- GitHub Secrets
- Keychains temporaires
- Base64 encoding

---

## Étape 6 : TestFlight Automatique

**Objectif : Déployer automatiquement sur TestFlight**

### Actions

1. Créer App Store Connect API Key
2. Ajouter la clé aux GitHub Secrets
3. Créer workflow `testflight.yml`
4. Utiliser `fastlane` pour l'upload

### Secrets supplémentaires

- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_CONTENT`

### Workflow `testflight.yml`

```yaml
name: Deploy to TestFlight

on:
  push:
    tags:
                                                                                 - 'v*-beta*'  # Ex: v1.0.0-beta1

jobs:
  deploy:
    runs-on: macos-latest
    steps:
                                                                                 - uses: actions/checkout@v4
      
      # ... Install certificate & profiles ...
      
                                                                                 - name: Build & Archive
        run: |
          xcodebuild archive \
            -scheme LiftBook \
            -configuration Release \
            -archivePath build/LiftBook.xcarchive \
            CODE_SIGN_STYLE=Manual
      
                                                                                 - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath build/LiftBook.xcarchive \
            -exportPath build \
            -exportOptionsPlist ExportOptions.plist
      
                                                                                 - name: Upload to TestFlight
        env:
          API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
        run: |
          xcrun altool --upload-app \
            -f build/LiftBook.ipa \
            -t ios \
            --apiKey $API_KEY_ID \
            --apiIssuer ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
```

### Fichier `ExportOptions.plist` à créer

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

**Learning points** :

- Archive & Export
- Tag-based deployment
- App Store Connect API
- IPA upload

---

## Étape 7 : Production (App Store)

**Objectif : Pipeline complète pour release production**

### Actions

1. Créer workflow `release.yml`
2. Trigger sur tags de release (ex: `v1.0.0`)
3. Générer release notes automatiques
4. Créer GitHub Release avec IPA en artifact

### Workflow `release.yml`

```yaml
name: Release to App Store

on:
  push:
    tags:
                                                                                 - 'v*'  # Ex: v1.0.0 (sans -beta)

jobs:
  release:
    runs-on: macos-latest
    steps:
                                                                                 - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Pour changelog
      
      # ... Build & Upload (même que TestFlight) ...
      
                                                                                 - name: Generate Changelog
        id: changelog
        run: |
          git log $(git describe --tags --abbrev=0 HEAD^)..HEAD --pretty=format:"- %s" > CHANGELOG.md
      
                                                                                 - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          files: build/LiftBook.ipa
          body_path: CHANGELOG.md
```

**Learning points** :

- Semantic versioning
- Changelog automation
- GitHub Releases

---

## Étape 8 : Optimisations & Monitoring

**Objectif : Améliorer la pipeline et ajouter du monitoring**

### Actions

1. Ajouter cache pour dépendances (SPM)
2. Paralléliser les jobs (lint + test + build)
3. Ajouter notifications Slack/Discord
4. Configurer branch protection rules

### Cache example

```yaml
- name: Cache SPM
  uses: actions/cache@v3
  with:
    path: .build
    key: ${{ runner.os }}-spm-${{ hashFiles('**/Package.resolved') }}
```

### Branch Protection

- Require status checks (lint + tests) avant merge
- Require review
- No force push sur main

**Learning points** :

- Performance CI
- Cache strategies
- Branch protection

---

## Structure Finale des Workflows

```
.github/
└── workflows/
    ├── lint.yml          # Sur chaque push/PR
    ├── tests.yml         # Sur chaque push/PR
    ├── build.yml         # Sur chaque push/PR
    ├── testflight.yml    # Sur tags beta
    └── release.yml       # Sur tags release
```

---

## Progression Suggérée

**Semaine 1** : Étapes 1-3 (Repo + Lint + Tests)

- Focus : Comprendre GitHub Actions basics
- Résultat : CI qui valide le code

**Semaine 2** : Étapes 4-5 (Build + Signing)

- Focus : Code signing complexité
- Résultat : Peut archiver l'app

**Semaine 3** : Étapes 6-7 (TestFlight + Release)

- Focus : Déploiement automatique
- Résultat : Pipeline complète

**Semaine 4** : Étape 8 (Optimisations)

- Focus : Best practices
- Résultat : Pipeline production-ready

---

## Resources & Documentation

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Xcodebuild Reference](https://developer.apple.com/library/archive/technotes/tn2339/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [SwiftLint Docs](https://github.com/realm/SwiftLint)

---

## Quick Commands de Référence

```bash
# Encoder certificat en base64
base64 -i certificate.p12 | pbcopy

# Encoder provisioning profile
base64 -i profile.mobileprovision | pbcopy

# Lister simulateurs disponibles
xcrun simctl list devices

# Test build locale
xcodebuild -list
xcodebuild build -scheme LiftBook
```

### To-dos

- [ ] Initialiser le repo GitHub avec .gitignore et README
- [ ] Configurer SwiftLint workflow et règles
- [ ] Configurer workflow de tests automatiques
- [ ] Configurer workflow de build validation
- [ ] Configurer code signing et secrets
- [ ] Configurer déploiement automatique TestFlight
- [ ] Configurer pipeline de release App Store
- [ ] Optimiser avec cache et monitoring