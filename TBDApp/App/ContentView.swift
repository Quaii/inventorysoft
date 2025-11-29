import SwiftUI

// MARK: - Navigation Enum
enum AppTab: String, CaseIterable, Identifiable {
    case dashboard
    case inventory
    case sales
    case purchases
    case analytics
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .inventory: return "Inventory"
        case .sales: return "Sales"
        case .purchases: return "Purchases"
        case .analytics: return "Analytics"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .inventory: return "box.truck"
        case .sales: return "tag"
        case .purchases: return "cart"
        case .analytics: return "chart.bar.xaxis"
        case .settings: return "gearshape"
        }
    }
}

// MARK: - Main Shell View (Replaces ContentView)
struct MainShellView: View {
    @State private var selectedTab: AppTab = .dashboard
    @Environment(\.theme) var theme
    @EnvironmentObject var appEnvironment: AppEnvironment

    var body: some View {
        AppSidebarContainer(
            sidebar: {
                sidebarContent
            },
            content: {
                mainContent
            }
        )
    }

    private var sidebarContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Logo/Header
            HStack(spacing: theme.spacing.s) {
                Image(systemName: "cube.transparent.fill")
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.accentPrimary)

                Text("TBDApp")
                    .font(theme.typography.headingM)
                    .foregroundColor(theme.colors.textPrimary)
            }
            .padding(.horizontal, theme.spacing.l)
            .padding(.bottom, theme.spacing.xl)

            // Navigation Items
            ScrollView {
                VStack(spacing: theme.spacing.xs) {
                    ForEach(AppTab.allCases) { tab in
                        AppSidebarItem(
                            icon: tab.icon,
                            label: tab.title,
                            isSelected: selectedTab == tab
                        ) {
                            selectedTab = tab
                        }
                    }
                }
                .padding(.horizontal, theme.spacing.s)
            }

            Spacer()
        }
        .padding(.vertical, theme.spacing.l)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch selectedTab {
        case .dashboard:
            DashboardView(viewModel: appEnvironment.makeDashboardViewModel())
        case .inventory:
            InventoryView(viewModel: appEnvironment.makeInventoryViewModel())
        case .sales:
            SalesListView(viewModel: appEnvironment.makeSalesViewModel())
        case .purchases:
            PurchasesListView(viewModel: appEnvironment.makePurchasesViewModel())
        case .analytics:
            VStack {
                AppHeader(title: "Analytics")
                Spacer()
                Text("Analytics Coming Soon")
                    .foregroundColor(theme.colors.textSecondary)
                Spacer()
            }
        case .settings:
            SettingsView(viewModel: appEnvironment.makeSettingsViewModel())
        }
    }
}

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
            Text("Welcome to TBDApp")
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
