//
//  OnboardingView.swift
//  LiftBook
//
//  Created by Méryl VALIER on 25/04/2026.
//

import SwiftData
import SwiftUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.restTimerNotificationService) private var restTimerNotificationService
    @Query(sort: \Exercise.name, order: .forward) private var exercises: [Exercise]

    @AppStorage(LBSettingsKeys.preferredWeightUnit) private var preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue
    @AppStorage(LBSettingsKeys.defaultRestTimerDurationSeconds) private var defaultRestTimerDurationSeconds = RestTimerDuration.defaultValue.rawValue
    @AppStorage(LBSettingsKeys.restTimerNotificationsEnabled) private var restTimerNotificationsEnabled = false

    let onComplete: () -> Void

    @State private var page: OnboardingPage = .intro
    @State private var setupState: OnboardingSetupState = .idle
    @State private var isRequestingRestAlertPermission = false
    @State private var isShowingRestAlertPermissionAlert = false

    private var preferredWeightUnit: Binding<WeightUnit> {
        Binding {
            WeightUnit(rawValue: preferredWeightUnitRawValue) ?? .kilograms
        } set: { unit in
            preferredWeightUnitRawValue = unit.rawValue
        }
    }

    private var defaultRestTimerDuration: RestTimerDuration {
        RestTimerDuration(seconds: defaultRestTimerDurationSeconds)
    }

    private var restAlertsPreference: Binding<Bool> {
        Binding {
            restTimerNotificationsEnabled
        } set: { isEnabled in
            updateRestAlertsPreference(isEnabled)
        }
    }

    var body: some View {
        ZStack {
            LBColor.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 28)
                    .padding(.top, 18)
                    .padding(.bottom, 8)

                ScrollView {
                    pageContent
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.horizontal, 28)
                        .padding(.top, 18)
                        .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)

                footer
            }
        }
        .tint(LBColor.workoutStart)
        .task {
            await prepareExerciseLibrary()
        }
        .alert("Notifications Disabled", isPresented: $isShowingRestAlertPermissionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Allow notifications for LiftBook in iOS Settings to turn rest alerts on.")
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            if page == .defaults {
                Button(action: showIntroPage) {
                    Label("Back", systemImage: "chevron.left")
                }
                .buttonStyle(OnboardingChromeButtonStyle())
            } else {
                appIdentity
            }

            Spacer(minLength: 12)

            Button("Skip", action: skipOnboarding)
                .buttonStyle(OnboardingChromeButtonStyle())
                .disabled(!setupState.isReady || isRequestingRestAlertPermission)
        }
    }

    private var appIdentity: some View {
        HStack(spacing: 10) {
            Image("SplashIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityHidden(true)

            Text("LiftBook")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case .intro:
            introPage
                .transition(.opacity)
        case .defaults:
            defaultsPage
                .transition(.opacity)
        }
    }

    private var introPage: some View {
        VStack(spacing: 34) {
            VStack(spacing: 26) {
                appMark

                VStack(spacing: 16) {
                    Text("Log your workout as you lift.")
                        .font(.system(size: 42, weight: .black, design: .default))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.primary)
                        .lineLimit(3)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Start from a routine, tap sets as you finish, and edit anything later.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 20)

            VStack(spacing: 12) {
                OnboardingFeatureRow(
                    systemImage: "checkmark.circle.fill",
                    title: "Log sets fast",
                    detail: "Reps, weight, and completion stay one tap away."
                )

                OnboardingFeatureRow(
                    systemImage: "timer",
                    title: "Rest between sets",
                    detail: "A timer starts when you finish a set."
                )

                OnboardingFeatureRow(
                    systemImage: "pencil",
                    title: "Edit anytime",
                    detail: "Fix reps, weight, notes, or exercises later."
                )
            }
        }
    }

    private var defaultsPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text("WORKOUT DEFAULTS")
                    .font(.footnote.weight(.heavy))
                    .tracking(2)
                    .foregroundStyle(.secondary)

                Text("Start with the settings you will use today.")
                    .font(.system(size: 36, weight: .black, design: .default))
                    .foregroundStyle(.primary)
                    .lineLimit(3)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)

                Text("These choices only affect logging speed. You can change them later.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 10)

            unitsCard
            defaultRestCard
            restAlertsCard
        }
    }

    private var unitsCard: some View {
        OnboardingSettingCard(
            title: "Units",
            detail: "Used for weight entries."
        ) {
            Picker("Weight unit", selection: preferredWeightUnit) {
                ForEach(WeightUnit.allCases) { unit in
                    Text(unit.rawValue)
                        .tag(unit)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var defaultRestCard: some View {
        OnboardingSettingCard(
            title: "Default rest",
            detail: "Applied after completing a set."
        ) {
            HStack(spacing: 14) {
                restAdjustmentButton(
                    systemImage: "minus",
                    accessibilityLabel: "Decrease default rest",
                    isDisabled: !canDecreaseRestTimerDuration,
                    action: { adjustDefaultRestTimerDuration(by: -1) }
                )

                Text(WorkoutDurationFormatter.countdownString(from: defaultRestTimerDuration.timeInterval))
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .background {
                        Capsule()
                            .fill(Color.black.opacity(0.16))
                    }

                restAdjustmentButton(
                    systemImage: "plus",
                    accessibilityLabel: "Increase default rest",
                    isDisabled: !canIncreaseRestTimerDuration,
                    action: { adjustDefaultRestTimerDuration(by: 1) }
                )
            }
        }
    }

    private var restAlertsCard: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Rest alerts")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)

                Text("Notify when the timer is over.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            if isRequestingRestAlertPermission {
                ProgressView()
                    .controlSize(.small)
            } else {
                Toggle("Rest alerts", isOn: restAlertsPreference)
                    .labelsHidden()
                    .disabled(isRequestingRestAlertPermission)
            }
        }
        .padding(22)
        .lbCardSurface()
    }

    private var footer: some View {
        VStack(spacing: 14) {
            setupStatusView

            Button(action: performPrimaryAction) {
                Text(primaryButtonTitle)
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
            }
            .buttonStyle(OnboardingPrimaryButtonStyle())
            .disabled(isPrimaryButtonDisabled)

            OnboardingPageIndicator(page: page)
        }
        .padding(.horizontal, 28)
        .padding(.top, 12)
        .padding(.bottom, 22)
        .background {
            LBColor.background
                .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder
    private var setupStatusView: some View {
        switch setupState {
        case .idle:
            setupStatusLabel("Preparing exercise library", systemImage: "clock")

        case .preparing(let imported, let total):
            VStack(spacing: 8) {
                if total > 0 {
                    ProgressView(value: Double(imported), total: Double(total))
                        .frame(maxWidth: 240)

                    Text("Importing \(imported) of \(total) exercises")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    ProgressView("Preparing exercise library")
                        .font(.footnote)
                }
            }
            .frame(maxWidth: .infinity)

        case .ready:
            EmptyView()

        case .failed(let message):
            VStack(spacing: 10) {
                setupStatusLabel("Setup failed", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    Task {
                        await prepareExerciseLibrary()
                    }
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var primaryButtonTitle: String {
        switch page {
        case .intro:
            return "Continue"
        case .defaults:
            return "Start lifting"
        }
    }

    private var isPrimaryButtonDisabled: Bool {
        page == .defaults && (!setupState.isReady || isRequestingRestAlertPermission)
    }

    private var appMark: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(.regularMaterial)
                .frame(width: 126, height: 126)
                .shadow(color: Color.black.opacity(0.22), radius: 18, y: 12)

            Image("SplashIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 92, height: 92)
                .accessibilityHidden(true)
        }
    }

    private var canDecreaseRestTimerDuration: Bool {
        restTimerDurationIndex > 0
    }

    private var canIncreaseRestTimerDuration: Bool {
        restTimerDurationIndex < RestTimerDuration.allCases.count - 1
    }

    private var restTimerDurationIndex: Int {
        RestTimerDuration.allCases.firstIndex(of: defaultRestTimerDuration) ?? 0
    }

    private func performPrimaryAction() {
        switch page {
        case .intro:
            showDefaultsPage()
        case .defaults:
            finishOnboarding()
        }
    }

    private func showIntroPage() {
        withAnimation(.easeInOut(duration: 0.2)) {
            page = .intro
        }
    }

    private func showDefaultsPage() {
        withAnimation(.easeInOut(duration: 0.2)) {
            page = .defaults
        }
    }

    private func finishOnboarding() {
        guard setupState.isReady, !isRequestingRestAlertPermission else {
            return
        }

        onComplete()
    }

    private func skipOnboarding() {
        guard setupState.isReady, !isRequestingRestAlertPermission else {
            return
        }

        preferredWeightUnitRawValue = WeightUnit.kilograms.rawValue
        defaultRestTimerDurationSeconds = RestTimerDuration.defaultValue.rawValue
        restTimerNotificationsEnabled = false

        Task {
            await restTimerNotificationService.cancelAllRestTimerNotifications()
        }

        onComplete()
    }

    private func adjustDefaultRestTimerDuration(by offset: Int) {
        let durations = RestTimerDuration.allCases
        let nextIndex = min(max(restTimerDurationIndex + offset, 0), durations.count - 1)
        defaultRestTimerDurationSeconds = durations[nextIndex].rawValue
    }

    private func updateRestAlertsPreference(_ isEnabled: Bool) {
        guard isEnabled else {
            restTimerNotificationsEnabled = false
            Task {
                await restTimerNotificationService.cancelAllRestTimerNotifications()
            }
            return
        }

        guard !isRequestingRestAlertPermission else {
            return
        }

        isRequestingRestAlertPermission = true

        Task {
            let isAuthorized = await restTimerNotificationService
                .requestAuthorizationFromUserAction()

            await MainActor.run {
                restTimerNotificationsEnabled = isAuthorized
                isRequestingRestAlertPermission = false
                isShowingRestAlertPermissionAlert = !isAuthorized
            }
        }
    }

    private func restAdjustmentButton(
        systemImage: String,
        accessibilityLabel: String,
        isDisabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.headline.weight(.bold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(OnboardingIconButtonStyle())
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel)
    }

    private func setupStatusLabel(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)
    }

    @MainActor
    private func prepareExerciseLibrary() async {
        guard !setupState.isPreparing, !setupState.isReady else {
            return
        }

        setupState = .preparing(imported: 0, total: 0)

        do {
            let result = try await ExerciseLibrarySeeder().prepareLibrary(
                into: modelContext,
                existingExercises: exercises
            ) { progress in
                setupState = .preparing(imported: progress.imported, total: progress.total)
            }

            setupState = .ready(count: result.count)
        } catch is CancellationError {
            return
        } catch {
            setupState = .failed(error.localizedDescription)
        }
    }
}

private struct OnboardingFeatureRow: View {
    let systemImage: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(LBColor.workoutStart.opacity(0.14))

                Image(systemName: systemImage)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(LBColor.workoutStart)
            }
            .frame(width: 42, height: 42)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .lbCardSurface()
    }
}

private struct OnboardingSettingCard<Content: View>: View {
    let title: String
    let detail: String
    let content: Content

    init(
        title: String,
        detail: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.detail = detail
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)

                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            content
        }
        .padding(22)
        .lbCardSurface()
    }
}

private struct OnboardingPageIndicator: View {
    let page: OnboardingPage

    var body: some View {
        HStack(spacing: 7) {
            indicator(isSelected: page == .intro)
            indicator(isSelected: page == .defaults)
        }
        .accessibilityHidden(true)
    }

    private func indicator(isSelected: Bool) -> some View {
        Capsule()
            .fill(isSelected ? LBColor.workoutStart : Color.secondary.opacity(0.35))
            .frame(width: isSelected ? 28 : 8, height: 8)
            .animation(.snappy(duration: 0.18), value: isSelected)
    }
}

private struct OnboardingPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(Color.black)
            .background {
                Capsule()
                    .fill(LBColor.workoutStart.opacity(isEnabled ? pressedOpacity(configuration) : 0.28))
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }

    private func pressedOpacity(_ configuration: Configuration) -> Double {
        configuration.isPressed ? 0.82 : 1
    }
}

private struct OnboardingChromeButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .foregroundStyle(Color.primary.opacity(isEnabled ? 0.78 : 0.32))
            .padding(.horizontal, 17)
            .frame(minHeight: 42)
            .background {
                Capsule()
                    .fill(Color.primary.opacity(configuration.isPressed ? 0.1 : 0.05))
            }
            .overlay {
                Capsule()
                    .stroke(Color.primary.opacity(isEnabled ? 0.15 : 0.07), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.97 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}

private struct OnboardingIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(LBColor.workoutStart.opacity(isEnabled ? 1 : 0.35))
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(LBColor.workoutStart.opacity(configuration.isPressed ? 0.18 : 0.1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LBColor.workoutStart.opacity(isEnabled ? 0.5 : 0.18), lineWidth: 1.2)
            }
            .scaleEffect(configuration.isPressed && isEnabled ? 0.96 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}

private enum OnboardingPage: Equatable {
    case intro
    case defaults
}

private enum OnboardingSetupState: Equatable {
    case idle
    case preparing(imported: Int, total: Int)
    case ready(count: Int)
    case failed(String)

    var isPreparing: Bool {
        if case .preparing = self {
            return true
        }
        return false
    }

    var isReady: Bool {
        if case .ready = self {
            return true
        }
        return false
    }
}

#Preview {
    OnboardingView {}
        .modelContainer(
            for: [
                Exercise.self,
                RoutineTemplate.self,
                RoutineTemplateExercise.self,
                RoutineTemplateSet.self,
                WorkoutSession.self,
                WorkoutSessionExercise.self,
                WorkoutSet.self,
            ],
            inMemory: true
        )
}
