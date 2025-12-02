import Charts
import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @State private var showingConfiguration = false
    @State private var showingAddWidget = false
    @State private var showingEditWidget = false
    @State private var showingContextMenu = false
    @State private var contextMenuWidget: UserWidget?
    @State private var editingWidget: UserWidget?
    @State private var contextMenuPosition: CGPoint = .zero

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Content
                    dashboardContent
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    headerButtons
                }
            }
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
            VStack(alignment: .leading, spacing: 24) {
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
            .padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private var mainWidgetGrid: some View {
        let chartWidgets = viewModel.userWidgets.filter { widget in
            widget.type.category == .charts && widget.isVisible
        }.sorted(by: { $0.position < $1.position })

        if !chartWidgets.isEmpty {
            DashboardWidgetGrid(
                widgets: chartWidgets,
                onWidgetTap: { widget in handleWidgetTap(widget) },
                onWidgetRemove: { widget in viewModel.removeWidget(widget) },
                onWidgetContextMenu: { widget, point in
                    contextMenuWidget = widget
                    contextMenuPosition = point
                    showingContextMenu = true
                },
                content: { widget in widgetContent(for: widget) }
            )
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            if #available(macOS 14.0, iOS 17.0, *) {
                ContentUnavailableView(
                    "Error Loading Dashboard",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
            } else {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                    Text("Error Loading Dashboard")
                        .font(.title2)
                    Text(message)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: {
                Task {
                    await viewModel.loadMetrics()
                }
            }) {
                Label("Retry", systemImage: "arrow.clockwise")
            }

            Button(
                role: .destructive,
                action: {
                    Task {
                        await viewModel.resetDashboard()
                    }
                }
            ) {
                Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
            }
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
        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                ],
                spacing: 16
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
                .frame(height: 240)

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
                .frame(height: 240)

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
                .frame(height: 240)
            }
        }
    }

    // MARK: - Computed Properties

    @ViewBuilder
    private var headerButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                showingAddWidget = true
            }) {
                Label("Add Widget", systemImage: "plus")
            }

            Button(action: {
                showingConfiguration = true
            }) {
                Label("Configure", systemImage: "slider.horizontal.3")
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
                        .foregroundColor(.secondary)
                    Text("Chart available in Analytics")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        print("Tapped widget: \(widget.name)")
    }
}
