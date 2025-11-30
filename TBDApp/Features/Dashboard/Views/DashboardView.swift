import Charts
import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @Environment(\.theme) var theme
    @State private var showingConfiguration = false

    var body: some View {
        AppScreenContainer {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Dashboard",
                    title: "Dashboard",
                    subtitle: "Track your inventory, sales, and key metrics"
                ) {
                    AppButton(
                        title: "Configure",
                        icon: "slider.horizontal.3",
                        style: .secondary
                    ) {
                        showingConfiguration = true
                    }
                }

                // Content
                if viewModel.isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading dashboard...")
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textSecondary)
                            .padding(.top, theme.spacing.m)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: theme.spacing.l) {
                        AppEmptyStateView(
                            title: "Error Loading Dashboard",
                            message: error,
                            icon: "exclamationmark.triangle",
                            actionTitle: "Retry",
                            action: {
                                Task {
                                    await viewModel.loadMetrics()
                                }
                            }
                        )

                        AppButton(
                            title: "Reset to Defaults",
                            icon: "arrow.counterclockwise",
                            style: .secondary
                        ) {
                            Task {
                                await viewModel.resetDashboard()
                            }
                        }
                        .frame(maxWidth: 300)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.xl) {
                        // Row 1: Three cards (System Overview, Total Items, Processes)
                        HStack(alignment: .top, spacing: theme.spacing.xl) {
                            SystemOverviewCard(
                                itemsPerDay: viewModel.itemsPerDay,
                                totalCaptured: viewModel.totalItems,
                                onSettingsAction: {
                                    showingConfiguration = true
                                }
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                            TotalItemsCard(
                                totalItems: viewModel.totalItems,
                                historicData: viewModel.itemCountHistory
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                            ProcessesCard(
                                alerts: viewModel.stockAlerts,
                                onViewAll: {
                                    // Navigate to inventory with low stock filter
                                },
                                onViewAlert: { alert in
                                    // Navigate to specific alert item
                                }
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: 320)

                        // Row 2: Recent Items (full width)
                        RecentItemsCard(
                            items: viewModel.recentItems,
                            onViewAll: {
                                // Navigate to inventory
                            },
                            onViewItem: { item in
                                // Navigate to item detail
                            }
                        )
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .inventorySoftModal(isPresented: $showingConfiguration, title: "Configure Dashboard") {
            DashboardConfigurationView(
                isPresented: $showingConfiguration, widgets: $viewModel.widgets)
        }
        .task {
            await viewModel.loadMetrics()
        }
        .onChange(of: viewModel.widgets) { _, newWidgets in
            Task {
                await viewModel.saveWidgetConfiguration(newWidgets)
            }
        }
    }
}
