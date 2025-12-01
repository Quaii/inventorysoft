import SwiftUI

struct MainShellView: View {
    @State private var selectedTab: AppTab = .dashboard
    @Namespace private var namespace
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            Sidebar(selectedTab: $selectedTab, namespace: namespace)
                .zIndex(1)

            // Main Content
            ZStack {
                theme.colors.backgroundPrimary
                    .ignoresSafeArea()

                switch selectedTab {
                case .dashboard:
                    DashboardView(viewModel: environment.makeDashboardViewModel())
                case .inventory:
                    InventoryView(viewModel: environment.makeInventoryViewModel())
                case .sales:
                    SalesListView(viewModel: environment.makeSalesViewModel())
                case .purchases:
                    PurchasesListView(viewModel: environment.makePurchasesViewModel())
                case .analytics:
                    AnalyticsView(viewModel: environment.makeAnalyticsViewModel())
                case .settings:
                    SettingsView(viewModel: environment.makeSettingsViewModel())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // No custom background
    }
}
