import SwiftUI

struct MainShellView: View {
    @State private var selectedTab: AppTab = .dashboard
    @Environment(\.theme) var theme
    @EnvironmentObject var appEnvironment: AppEnvironment

    @State private var isSidebarCollapsed = false
    @Namespace private var namespace

    var body: some View {
        #if os(macOS)
            NavigationSplitView {
                List(selection: $selectedTab) {
                    NavigationLink(value: AppTab.dashboard) {
                        Label("Dashboard", systemImage: "square.grid.2x2")
                    }
                    NavigationLink(value: AppTab.inventory) {
                        Label("Inventory", systemImage: "cube.box")
                    }
                    NavigationLink(value: AppTab.sales) {
                        Label("Sales", systemImage: "tag")
                    }
                    NavigationLink(value: AppTab.purchases) {
                        Label("Purchases", systemImage: "cart")
                    }
                    NavigationLink(value: AppTab.analytics) {
                        Label("Analytics", systemImage: "chart.bar")
                    }
                    NavigationLink(value: AppTab.settings) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
                .background(.ultraThinMaterial)  // Transparent sidebar
            } detail: {
                mainContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.colors.backgroundPrimary)  // Opaque main content
            }
            .navigationSplitViewStyle(.balanced)
        #else
            // iOS / iPadOS Layout
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: appEnvironment.makeDashboardViewModel())
                    .tabItem {
                        Label("Dashboard", systemImage: "square.grid.2x2")
                    }
                    .tag(AppTab.dashboard)

                InventoryView(viewModel: appEnvironment.makeInventoryViewModel())
                    .tabItem {
                        Label("Inventory", systemImage: "cube.box")
                    }
                    .tag(AppTab.inventory)

                SalesListView(viewModel: appEnvironment.makeSalesViewModel())
                    .tabItem {
                        Label("Sales", systemImage: "tag")
                    }
                    .tag(AppTab.sales)

                PurchasesListView(viewModel: appEnvironment.makePurchasesViewModel())
                    .tabItem {
                        Label("Purchases", systemImage: "cart")
                    }
                    .tag(AppTab.purchases)

                AnalyticsView(viewModel: appEnvironment.makeAnalyticsViewModel())
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar")
                    }
                    .tag(AppTab.analytics)

                SettingsView(viewModel: appEnvironment.makeSettingsViewModel())
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(AppTab.settings)
            }
        #endif
    }

    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            // Content views
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
                AnalyticsView(viewModel: appEnvironment.makeAnalyticsViewModel())
            case .settings:
                SettingsView(viewModel: appEnvironment.makeSettingsViewModel())
            }
        }
    }
}
