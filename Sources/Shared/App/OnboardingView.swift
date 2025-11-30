import SwiftUI

// MARK: - Onboarding View Model
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedCurrency: String = "USD"
    @Published var selectedThemeMode: String = "System"

    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case preferences
        case importTeaser
        case finish
    }

    func nextStep() {
        if let next = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentStep = next
            }
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.theme) var theme

    var body: some View {
        ZStack {
            // Background
            theme.colors.backgroundPrimary
                .ignoresSafeArea()

            // Ambient Glow
            Circle()
                .fill(theme.colors.accentSecondary.opacity(0.15))
                .frame(width: 600, height: 600)
                .blur(radius: 100)
                .offset(x: -200, y: -200)

            Circle()
                .fill(theme.colors.accentTertiary.opacity(0.1))
                .frame(width: 500, height: 500)
                .blur(radius: 100)
                .offset(x: 200, y: 200)

            // Content
            VStack {
                Spacer()

                // Glass Card
                VStack(spacing: theme.spacing.xl) {
                    // Header / Icon
                    Image(systemName: "cube.transparent.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    theme.colors.accentSecondary, theme.colors.accentTertiary,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.bottom, theme.spacing.m)
                        .shadow(
                            color: theme.colors.accentSecondary.opacity(0.3), radius: 20, x: 0,
                            y: 10)

                    // Step Content
                    Group {
                        switch viewModel.currentStep {
                        case .welcome:
                            welcomeStep
                        case .preferences:
                            preferencesStep
                        case .importTeaser:
                            importTeaserStep
                        case .finish:
                            finishStep
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))

                    // Navigation
                    HStack {
                        if viewModel.currentStep != .welcome {
                            Button(action: {
                                // Back logic could be implemented here if needed
                            }) {
                                Text("Back")
                                    .font(theme.typography.bodyM)
                                    .foregroundColor(theme.colors.textSecondary)
                            }
                            .buttonStyle(.plain)
                            .opacity(0)  // Hidden for now to keep flow forward-only for simplicity
                        }

                        Spacer()

                        Button(action: {
                            if viewModel.currentStep == .finish {
                                appEnvironment.completeOnboarding()
                            } else {
                                viewModel.nextStep()
                            }
                        }) {
                            Text(viewModel.currentStep == .finish ? "Get Started" : "Next")
                                .font(theme.typography.buttonLabel)
                                .foregroundColor(theme.colors.textInversePrimary)
                                .padding(.horizontal, theme.spacing.l)
                                .padding(.vertical, theme.spacing.s)
                                .background(theme.colors.accentPrimary)
                                .cornerRadius(theme.radii.medium)
                        }
                        .buttonStyle(.plain)
                        .shadow(
                            color: theme.colors.accentPrimary.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, theme.spacing.l)
                }
                .padding(theme.spacing.xxl)
                .frame(maxWidth: 550)
                .glassBackground(cornerRadius: 24)

                Spacer()
            }
            .padding(theme.spacing.l)
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: theme.spacing.m) {
            Text("Welcome to InventoryFlow")
                .font(theme.typography.headingXL)
                .foregroundColor(theme.colors.textPrimary)
                .multilineTextAlignment(.center)

            Text("The professional, offline-first platform for modern sellers.")
                .font(theme.typography.bodyL)
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }

    private var preferencesStep: some View {
        VStack(spacing: theme.spacing.l) {
            Text("Quick Setup")
                .font(theme.typography.headingL)
                .foregroundColor(theme.colors.textPrimary)

            // Currency Picker
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                Text("Base Currency")
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.textSecondary)

                HStack {
                    ForEach(["USD", "EUR", "GBP", "JPY"], id: \.self) { currency in
                        Button(action: { viewModel.selectedCurrency = currency }) {
                            Text(currency)
                                .font(theme.typography.body)
                                .foregroundColor(
                                    viewModel.selectedCurrency == currency
                                        ? theme.colors.textInversePrimary : theme.colors.textPrimary
                                )
                                .padding(.horizontal, theme.spacing.m)
                                .padding(.vertical, theme.spacing.s)
                                .background(
                                    RoundedRectangle(cornerRadius: theme.radii.small)
                                        .fill(
                                            viewModel.selectedCurrency == currency
                                                ? theme.colors.accentPrimary
                                                : theme.colors.surfaceElevated)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.radii.small)
                                        .stroke(theme.colors.borderSubtle, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Theme Picker
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                Text("Theme Mode")
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.textSecondary)

                HStack {
                    ForEach(["System", "Dark", "Light"], id: \.self) { mode in
                        Button(action: { viewModel.selectedThemeMode = mode }) {
                            Text(mode)
                                .font(theme.typography.body)
                                .foregroundColor(
                                    viewModel.selectedThemeMode == mode
                                        ? theme.colors.textInversePrimary : theme.colors.textPrimary
                                )
                                .padding(.horizontal, theme.spacing.m)
                                .padding(.vertical, theme.spacing.s)
                                .background(
                                    RoundedRectangle(cornerRadius: theme.radii.small)
                                        .fill(
                                            viewModel.selectedThemeMode == mode
                                                ? theme.colors.accentPrimary
                                                : theme.colors.surfaceElevated)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.radii.small)
                                        .stroke(theme.colors.borderSubtle, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var importTeaserStep: some View {
        VStack(spacing: theme.spacing.m) {
            Text("Import Data")
                .font(theme.typography.headingL)
                .foregroundColor(theme.colors.textPrimary)

            Text(
                "Already have data? You can import your inventory from JSON files later in Settings."
            )
            .font(theme.typography.bodyM)
            .foregroundColor(theme.colors.textSecondary)
            .multilineTextAlignment(.center)

            Image(systemName: "arrow.down.doc")
                .font(.system(size: 48))
                .foregroundColor(theme.colors.accentSecondary.opacity(0.8))
                .padding()
                .background(
                    Circle()
                        .fill(theme.colors.accentSecondary.opacity(0.1))
                        .frame(width: 100, height: 100)
                )
        }
    }

    private var finishStep: some View {
        VStack(spacing: theme.spacing.m) {
            Text("All Set!")
                .font(theme.typography.headingL)
                .foregroundColor(theme.colors.textPrimary)

            Text("You're ready to start managing your business.")
                .font(theme.typography.bodyM)
                .foregroundColor(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}
