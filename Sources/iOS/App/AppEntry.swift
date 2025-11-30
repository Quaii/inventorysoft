import SwiftUI

@main
struct InventoryFlowApp: App {
    @StateObject private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            let themeMode =
                ThemeMode(rawValue: appEnvironment.userPreferences.themeMode.lowercased()) ?? .dark

            if appEnvironment.hasCompletedOnboarding {
                MainShellView()
                    .environmentObject(appEnvironment)
                    .environment(\.theme, appEnvironment.currentTheme)
                    .preferredColorScheme(preferredColorScheme(for: themeMode))
                    .tint(appEnvironment.currentTheme.colors.accentPrimary)
            } else {
                OnboardingView()
                    .environmentObject(appEnvironment)
                    .environment(\.theme, appEnvironment.currentTheme)
                    .preferredColorScheme(preferredColorScheme(for: themeMode))
                    .tint(appEnvironment.currentTheme.colors.accentPrimary)
            }
        }
    }

    private func preferredColorScheme(for mode: ThemeMode) -> ColorScheme? {
        switch mode {
        case .dark:
            return .dark
        case .light:
            return .light
        case .system:
            return nil
        }
    }
}
