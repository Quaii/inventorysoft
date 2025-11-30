import SwiftUI

struct MainShellView: View {
    @State private var selectedTab: AppTab = .dashboard
    @Environment(\.theme) var theme
    @EnvironmentObject var appEnvironment: AppEnvironment

    var body: some View {
        AppSidebarContainer(
            sidebar: { isCollapsed in
                sidebarContent(isCollapsed: isCollapsed)
            },
            content: {
                mainContent
            }
        )
    }

    private func sidebarContent(isCollapsed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // App Logo/Header
            HStack(spacing: theme.spacing.s) {
                Image(systemName: "cube.transparent.fill")
                    .font(.system(size: 24))
                    .foregroundColor(theme.colors.accentPrimary)

                if !isCollapsed {
                    Text("Inventory Soft")
                        .font(theme.typography.headingM)
                        .foregroundColor(theme.colors.textPrimary)
                }
            }
            .padding(.horizontal, isCollapsed ? theme.spacing.s : theme.spacing.l)
            .padding(.bottom, theme.spacing.xl)
            .frame(maxWidth: .infinity, alignment: isCollapsed ? .center : .leading)

            // Navigation Items
            ScrollView {
                VStack(spacing: theme.spacing.xs) {
                    ForEach(AppTab.allCases) { tab in
                        AppSidebarItem(
                            icon: tab.icon,
                            label: tab.title,
                            isSelected: selectedTab == tab,
                            isCollapsed: isCollapsed
                        ) {
                            selectedTab = tab
                        }
                    }
                }
                .padding(.horizontal, theme.spacing.s)
            }
            .inventorySoftScrollStyle()

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
            AnalyticsView(viewModel: appEnvironment.makeAnalyticsViewModel())
        case .settings:
            SettingsView(viewModel: appEnvironment.makeSettingsViewModel())
        }
    }
}
