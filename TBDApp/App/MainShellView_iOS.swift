#if os(iOS)
    import SwiftUI

    struct MainShellView_iOS: View {
        @State private var selectedTab: AppTab = .dashboard
        @EnvironmentObject var environment: AppEnvironment
        @Environment(\.theme) var theme

        var body: some View {
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: environment.makeDashboardViewModel())
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.bar.fill")
                    }
                    .tag(AppTab.dashboard)

                InventoryView(viewModel: environment.makeInventoryViewModel())
                    .tabItem {
                        Label("Inventory", systemImage: "cube.box.fill")
                    }
                    .tag(AppTab.inventory)

                SalesListView(viewModel: environment.makeSalesViewModel())
                    .tabItem {
                        Label("Sales", systemImage: "tag.fill")
                    }
                    .tag(AppTab.sales)

                PurchasesListView(viewModel: environment.makePurchasesViewModel())
                    .tabItem {
                        Label("Purchases", systemImage: "cart.fill")
                    }
                    .tag(AppTab.purchases)

                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(AppTab.analytics)

                SettingsView(viewModel: environment.makeSettingsViewModel())
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(AppTab.settings)
            }
            .accentColor(theme.colors.accentPrimary)
        }
    }
#endif
