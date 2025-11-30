import Charts
import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @Environment(\.theme) var theme
    @State private var showingConfiguration = false
    @State private var showingAddWidget = false
    @State private var showingEditWidget = false
    @State private var showingContextMenu = false
    @State private var contextMenuWidget: UserWidget?
    @State private var editingWidget: UserWidget?
    @State private var contextMenuPosition: CGPoint = .zero
    @State private var isEditMode = false

    var body: some View {
        AppScreenContainer {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Dashboard",
                    title: "Dashboard",
                    subtitle: "Track your inventory, sales, and key metrics"
                ) {
                    headerButtons
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
                    ScrollView {
                        VStack(alignment: .leading, spacing: theme.spacing.xl) {
                            // KPI Row (Phase 2)
                            KPIGridView(kpis: viewModel.kpis, onKPITap: viewModel.handleKPITap)

                            // Priority Alerts (Phase 3)
                            if !viewModel.stockAlerts.isEmpty {
                                PriorityAlertsSection(alerts: viewModel.stockAlerts)
                            }

                            // Quick Lists (Phase 4)
                            HStack(alignment: .top, spacing: theme.spacing.l) {
                                QuickListCard(
                                    title: "Recent Sales",
                                    items: viewModel.recentSales,
                                    onTap: { print("Tapped sale: $0") }
                                )

                                QuickListCard(
                                    title: "Recent Purchases",
                                    items: viewModel.recentPurchases,
                                    onTap: { print("Tapped purchase: $0") }
                                )

                                QuickListCard(
                                    title: "Recent Items",
                                    items: viewModel.recentItems,
                                    onTap: { print("Tapped item: $0") }
                                )
                            }

                            // User Widgets Grid (Phase 5)
                            DashboardWidgetGrid(
                                widgets: viewModel.userWidgets,
                                isEditMode: isEditMode,
                                onWidgetTap: { widget in
                                    if !isEditMode {
                                        // TODO: Open widget detail/config
                                        print("Tapped widget: \(widget.name)")
                                    }
                                },
                                onWidgetRemove: { widget in
                                    viewModel.removeWidget(widget)
                                },
                                onWidgetContextMenu: { widget, position in
                                    if !isEditMode {
                                        contextMenuWidget = widget
                                        contextMenuPosition = position
                                        showingContextMenu = true
                                    }
                                },
                                onReorder: { source, destination in
                                    viewModel.reorderWidget(from: source, to: destination)
                                }
                            )

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
                                    onAlertTap: { alert in
                                        print("Tapped alert: \(alert.title)")
                                    }
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .frame(height: 300)

                            // Row 2: Recent Items (full width)
                            RecentItemsCard(
                                recentItems: viewModel.recentItemsAdded,
                                onItemTap: { item in
                                    print("Tapped item: \(item.name)")
                                }
                            )
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingConfiguration) {
            DashboardConfigurationView(isPresented: $showingConfiguration)
        }
        .sheet(isPresented: $showingAddWidget) {
            AddWidgetModal(isPresented: $showingAddWidget) { type, size, name in
                viewModel.addWidget(type: type, size: size, name: name)
            }
        }
        .sheet(isPresented: $showingEditWidget) {
            if let widget = editingWidget {
                EditWidgetModal(
                    isPresented: $showingEditWidget,
                    widget: Binding(
                        get: { widget },
                        set: { editingWidget = $0 }
                    )
                ) { updatedWidget in
                    viewModel.updateWidget(updatedWidget)
                }
            }
        }
        .overlay {
            if showingContextMenu, let widget = contextMenuWidget {
                WidgetContextMenuOverlay(
                    isPresented: $showingContextMenu,
                    widget: widget,
                    position: contextMenuPosition,
                    onConfigure: {
                        editingWidget = widget
                        showingContextMenu = false
                        showingEditWidget = true
                    },
                    onDuplicate: {
                        viewModel.duplicateWidget(widget)
                    },
                    onChangeSize: { newSize in
                        viewModel.changeWidgetSize(widget, to: newSize)
                    },
                    onRemove: {
                        viewModel.removeWidget(widget)
                    }
                )
            }
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

    // MARK: - Computed Properties

    @ViewBuilder
    private var headerButtons: some View {
        HStack(spacing: theme.spacing.m) {
            // Edit Mode Toggle
            AppButton(
                title: isEditMode ? "Done" : "Edit",
                icon: isEditMode ? "checkmark" : "pencil",
                style: isEditMode ? .primary : .secondary
            ) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditMode.toggle()
                }
            }

            if !isEditMode {
                AppButton(
                    title: "Add Widget",
                    icon: "plus",
                    style: .secondary
                ) {
                    showingAddWidget = true
                }

                AppButton(
                    title: "Configure",
                    icon: "slider.horizontal.3",
                    style: .secondary
                ) {
                    showingConfiguration = true
                }
            }
        }
    }
}
