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
        // Content (no background - let MainShellView handle it)
        ScrollView {
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
                dashboardContent
            }
            .padding(theme.spacing.xl)
            .frame(maxWidth: 1400, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .inventorySoftScrollStyle()
        .sheet(isPresented: $showingConfiguration) {
            DashboardConfigurationView(
                isPresented: $showingConfiguration,
                widgets: $viewModel.widgets
            )
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

    // MARK: - Content Views

    @ViewBuilder
    private var dashboardContent: some View {
        if viewModel.isLoading {
            ProgressView()
                .scaleEffect(1.2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            errorView(message: error)
        } else {
            VStack(alignment: .leading, spacing: theme.layout.sectionSpacing) {
                // SECTION 1: KPI Row
                KPIWidgetRowView(
                    widgets: viewModel.userWidgets.filter {
                        $0.type.category == .metrics && $0.isVisible
                    },
                    kpiData: convertKPIData(),
                    isLoading: viewModel.isLoading
                )

                // SECTION 2: Main Widget Grid (Charts)
                mainWidgetGrid

                // SECTION 3: Recent Lists
                recentListsSection
            }
            .padding(.bottom, theme.layout.sectionSpacing)
        }
    }

    @ViewBuilder
    private var mainWidgetGrid: some View {
        let chartWidgets = viewModel.userWidgets.filter { widget in
            widget.type.category == .charts && widget.isVisible
        }.sorted(by: { $0.position < $1.position })

        if !chartWidgets.isEmpty {
            WidgetGrid(
                items: chartWidgets,
                isEditing: isEditMode,
                content: { widget in
                    DashboardWidgetCard(
                        widget: widget,
                        isEditMode: isEditMode,
                        onTap: { handleWidgetTap(widget) },
                        onRemove: { viewModel.removeWidget(widget) },
                        onContextMenu: { point in
                            contextMenuWidget = widget
                            contextMenuPosition = point
                            showingContextMenu = true
                        },
                        content: { widgetContent(for: widget) }
                    )

                },
                onReorder: { from, to in
                    viewModel.reorderWidget(from: from, to: to)
                }
            )
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: theme.spacing.l) {
            AppEmptyStateView(
                title: "Error Loading Dashboard",
                message: message,
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
    }

    // Helper to convert KPI array to dictionary for the view
    private func convertKPIData() -> [DashboardWidgetType: String] {
        var data: [DashboardWidgetType: String] = [:]
        for kpi in viewModel.kpis {
            // Find widget type that corresponds to this KPI metric
            if let type = DashboardWidgetType.allCases.first(where: {
                $0.kpiMetricType == kpi.metricKey
            }) {
                data[type] = kpi.value
            }
        }
        return data
    }

    // MARK: - Section Views

    /// Section 3: Recent Lists Row
    @ViewBuilder
    private var recentListsSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.m) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: theme.layout.cardSpacing),
                    GridItem(.flexible(), spacing: theme.layout.cardSpacing),
                    GridItem(.flexible(), spacing: theme.layout.cardSpacing),
                ],
                spacing: theme.layout.cardSpacing
            ) {
                // Recent Sales
                QuickListCard(
                    title: "Recent Sales",
                    items: viewModel.recentSales,
                    onViewAll: {
                        print("View all sales")
                    },
                    onItemTap: { item in
                        print("Tapped sale: \(item.title)")
                    }
                )
                .frame(height: theme.layout.quickListCardHeight)

                // Recent Purchases
                QuickListCard(
                    title: "Recent Purchases",
                    items: viewModel.recentPurchases,
                    onViewAll: {
                        print("View all purchases")
                    },
                    onItemTap: { item in
                        print("Tapped purchase: \(item.title)")
                    }
                )
                .frame(height: theme.layout.quickListCardHeight)

                // Recent Items
                QuickListCard(
                    title: "Recent Items",
                    items: viewModel.recentlyAddedItems,
                    onViewAll: {
                        print("View all items")
                    },
                    onItemTap: { item in
                        print("Tapped item: \(item.title)")
                    }
                )
                .frame(height: theme.layout.quickListCardHeight)
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

    // MARK: - Helper Methods

    @ViewBuilder
    private func widgetContent(for widget: UserWidget) -> some View {
        Group {
            switch widget.type {
            // KPI Widgets (shouldn't appear here, but handle gracefully)
            case .kpiInventoryValue, .kpiItemsInStock, .kpiItemsListed,
                .kpiSoldMonth, .kpiRevenueMonth, .kpiProfitMonth:
                EmptyView()

            // Quick List Widgets (shouldn't appear here, but handle gracefully)
            case .quickListSales, .quickListPurchases, .quickListItems:
                EmptyView()

            // Alert Widgets (shouldn't appear here)
            case .priorityAlerts:
                EmptyView()

            // Chart Widgets
            case .revenueChart, .profitChart, .itemsSoldOverTime,
                .topCategories, .topBrands, .averageSalePrice, .customFormula:
                VStack {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 24))
                        .foregroundColor(theme.colors.textSecondary)
                    Text("Chart available in Analytics")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: widgetHeight(for: widget))
    }

    private func widgetHeight(for widget: UserWidget) -> CGFloat {
        switch widget.size {
        case .small: return 120
        case .medium: return 180
        case .large: return 240
        }
    }

    private func handleWidgetTap(_ widget: UserWidget) {
        if !isEditMode {
            print("Tapped widget: \(widget.name)")
        }
    }
}
