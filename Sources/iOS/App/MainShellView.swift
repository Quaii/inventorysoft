import SwiftUI

struct MainShellView: View {
    @State private var selectedTab: AppTab = .dashboard
    @EnvironmentObject var environment: AppEnvironment
    @Environment(\.theme) var theme

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: environment.makeDashboardViewModel())
                    .tag(AppTab.dashboard)

                InventoryView(viewModel: environment.makeInventoryViewModel())
                    .tag(AppTab.inventory)

                SalesListView(viewModel: environment.makeSalesViewModel())
                    .tag(AppTab.sales)

                PurchasesListView(viewModel: environment.makePurchasesViewModel())
                    .tag(AppTab.purchases)

                AnalyticsView(viewModel: environment.makeAnalyticsViewModel())
                    .tag(AppTab.analytics)

                SettingsView(viewModel: environment.makeSettingsViewModel())
                    .tag(AppTab.settings)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))  // Hide default tab bar
            .ignoresSafeArea()

            // Custom Floating Tab Bar
            HStack(spacing: 0) {
                ForEach(AppTab.allCases) { tab in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(
                                    .system(size: 20, weight: selectedTab == tab ? .bold : .medium)
                                )
                                .symbolVariant(selectedTab == tab ? .fill : .none)

                            Text(tab.title)
                                .font(
                                    .system(
                                        size: 10, weight: selectedTab == tab ? .semibold : .medium))
                        }
                        .foregroundColor(
                            selectedTab == tab
                                ? theme.colors.accentPrimary : theme.colors.textSecondary
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                }
            }
            .padding(.horizontal, theme.spacing.s)
            .padding(.bottom, 34)  // Safe area approximation (dynamic in real app)
            .background(
                theme.colors.surfaceGlass
                    .background(.ultraThinMaterial)
            )
            .cornerRadius(32, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: -5)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// Helper for corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
