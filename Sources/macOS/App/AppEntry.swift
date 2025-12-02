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
                    .preferredColorScheme(preferredColorScheme(for: themeMode))
                    .tint(Theme.accentColor)
                    .frame(minWidth: 900, minHeight: 600)  // Enforce minimum resolution

                    .transparentWindow(opacity: 1)  // Custom transparent window
            } else {
                OnboardingView()
                    .environmentObject(appEnvironment)
                    .preferredColorScheme(preferredColorScheme(for: themeMode))
                    .tint(Theme.accentColor)
                    .frame(minWidth: 900, minHeight: 600)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            SidebarCommands()
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
