import SwiftUI

@main
struct TBDApp: App {
    @StateObject private var appEnvironment = AppEnvironment()

    init() {
        ThemeConfigurator.configure(Theme.standard)
    }

    var body: some Scene {
        WindowGroup {
            if appEnvironment.hasCompletedOnboarding {
                MainShellView()
                    .environmentObject(appEnvironment)
                    .preferredColorScheme(.dark)
                    .tint(Theme.standard.colors.accentPrimary)
            } else {
                OnboardingView()
                    .environmentObject(appEnvironment)
                    .preferredColorScheme(.dark)
                    .tint(Theme.standard.colors.accentPrimary)
            }
        }
        #if os(macOS)
            .windowStyle(.hiddenTitleBar)
            .commands {
                SidebarCommands()
            }
        #endif
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
