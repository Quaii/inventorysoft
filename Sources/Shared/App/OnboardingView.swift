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
            withAnimation {
                currentStep = next
            }
        } else {
            // Complete logic handled in View
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appEnvironment: AppEnvironment
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack {
                Spacer()

                AppCard {
                    VStack(spacing: theme.spacing.l) {
                        // Header / Icon
                        Image(systemName: "cube.transparent.fill")
                            .font(.system(size: 64))
                            .foregroundColor(theme.colors.accentPrimary)
                            .padding(.bottom, theme.spacing.m)

                        // Step Content
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

                        // Navigation
                        HStack {
                            if viewModel.currentStep != .welcome {
                                AppButton(title: "Back", style: .ghost) {
                                    // Back logic
                                }
                            }

                            Spacer()

                            AppButton(
                                title: viewModel.currentStep == .finish ? "Get Started" : "Next"
                            ) {
                                if viewModel.currentStep == .finish {
                                    appEnvironment.completeOnboarding()
                                } else {
                                    viewModel.nextStep()
                                }
                            }
                        }
                        .padding(.top, theme.spacing.m)
                    }
                    .padding(theme.spacing.xl)
                    .frame(maxWidth: 500)
                }

                Spacer()
            }
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: theme.spacing.m) {
            Text("Welcome to Inventory Soft")
                .font(theme.typography.headingXL)
                .foregroundColor(theme.colors.textPrimary)
                .multilineTextAlignment(.center)

            Text(
                "Your local-first solution for inventory management, sales tracking, and analytics."
            )
            .font(theme.typography.bodyL)
            .foregroundColor(theme.colors.textSecondary)
            .multilineTextAlignment(.center)
        }
    }

    private var preferencesStep: some View {
        VStack(spacing: theme.spacing.m) {
            Text("Quick Setup")
                .font(theme.typography.headingL)
                .foregroundColor(theme.colors.textPrimary)

            AppDropdown(
                label: "Base Currency",
                options: ["USD", "EUR", "GBP", "JPY"],
                selection: $viewModel.selectedCurrency
            )

            AppDropdown(
                label: "Theme Mode",
                options: ["System", "Dark", "Light"],
                selection: $viewModel.selectedThemeMode
            )
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
                .foregroundColor(theme.colors.textSecondary.opacity(0.5))
                .padding()
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
