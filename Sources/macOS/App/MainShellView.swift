import SwiftUI

struct MainShellView: View {
    @State private var selectedTab: AppTab = .dashboard
    @Environment(\.theme) var theme
    @EnvironmentObject var appEnvironment: AppEnvironment

    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            Sidebar(selectedTab: $selectedTab, namespace: namespace)
                .zIndex(1)

            // Main Content
            ZStack {
                // Semi-transparent background to allow window transparency
                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                mainContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // No custom background
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
            AnalyticsView(viewModel: appEnvironment.makeAnalyticsViewModel())
        case .settings:
            SettingsView(viewModel: appEnvironment.makeSettingsViewModel())
        }
    }
}
