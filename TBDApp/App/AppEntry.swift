import SwiftUI

@main
struct TBDApp: App {
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
        #if os(macOS)
            .windowStyle(.hiddenTitleBar)
            .commands {
                SidebarCommands()
            }
        #endif
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

struct ContentView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        #if os(macOS)
            NavigationSplitView {
                List {
                    NavigationLink(
                        "Dashboard",
                        destination: DashboardView(viewModel: env.makeDashboardViewModel()))
                    NavigationLink(
                        "Inventory",
                        destination: InventoryView(viewModel: env.makeInventoryViewModel()))
                    NavigationLink(
                        "Sales", destination: SalesListView(viewModel: env.makeSalesViewModel()))
                    NavigationLink(
                        "Purchases",
                        destination: PurchasesListView(viewModel: env.makePurchasesViewModel()))
                    NavigationLink(
                        "Settings",
                        destination: SettingsView(viewModel: env.makeSettingsViewModel()))
                }
                .listStyle(.sidebar)
            } detail: {
                Text("Select an item")
            }
        #else
            TabView {
                DashboardView(viewModel: env.makeDashboardViewModel())
                    .tabItem { Label("Dashboard", systemImage: "chart.bar") }
                InventoryView(viewModel: env.makeInventoryViewModel())
                    .tabItem { Label("Inventory", systemImage: "cube.box") }
                SalesListView(viewModel: env.makeSalesViewModel())
                    .tabItem { Label("Sales", systemImage: "tag") }
                PurchasesListView(viewModel: env.makePurchasesViewModel())
                    .tabItem { Label("Purchases", systemImage: "cart") }
                SettingsView(viewModel: env.makeSettingsViewModel())
                    .tabItem { Label("Settings", systemImage: "gear") }
            }
        #endif
    }
}
