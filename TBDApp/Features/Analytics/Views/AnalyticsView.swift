import Charts
import SwiftUI

struct AnalyticsView: View {
    @StateObject var viewModel: AnalyticsViewModel
    @Environment(\.theme) var theme
    @State private var timeRange: String = "Last 30 Days"

    // Custom UI state
    @State private var showingChartEditor = false
    @State private var editingChart: ChartDefinition?
    @State private var showingDeleteConfirmation = false
    @State private var chartToDelete: ChartDefinition?
    @State private var showingContextMenu = false
    @State private var contextMenuChart: ChartDefinition?

    // Grid layout
    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 500), spacing: 24)
    ]

    var body: some View {
        AppScreenContainer {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Analytics",
                    title: "Analytics",
                    subtitle: "Deep dive into your business metrics"
                ) {
                    HStack(spacing: theme.spacing.s) {
                        AppDropdown(
                            options: ["Last 7 Days", "Last 30 Days", "This Year"],
                            selection: $timeRange
                        )
                        .frame(width: 160)

                        AppButton(title: "Add Chart", icon: "plus", style: .primary) {
                            editingChart = nil
                            showingChartEditor = true
                        }
                    }
                }

                // Content
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if let error = viewModel.errorMessage {
                    AppEmptyStateView(
                        title: "Error Loading Charts",
                        message: error,
                        icon: "exclamationmark.triangle",
                        actionTitle: "Retry",
                        action: {
                            Task { await viewModel.loadCharts() }
                        }
                    )
                } else if viewModel.charts.isEmpty {
                    AppEmptyStateView(
                        title: "No Charts Configured",
                        message: "Add your first chart to start tracking metrics.",
                        icon: "chart.bar.xaxis",
                        actionTitle: "Add Chart",
                        action: {
                            editingChart = nil
                            showingChartEditor = true
                        }
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: theme.spacing.xl) {
                        ForEach(viewModel.charts) { chart in
                            chartCard(for: chart)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .task {
            await viewModel.loadCharts()
        }
        .overlay {
            // Custom chart editor modal
            if showingChartEditor {
                ChartEditorView(
                    chart: editingChart,
                    onSave: { chart in
                        if editingChart == nil {
                            // Create mode
                            viewModel.addChart(chart)
                        } else {
                            // Edit mode
                            viewModel.updateChart(chart)
                        }
                        editingChart = nil
                    },
                    isPresented: $showingChartEditor
                )
            }
        }
        .overlay {
            // Custom delete confirmation
            if showingDeleteConfirmation, let chart = chartToDelete {
                ChartDeleteConfirmationView(
                    isPresented: $showingDeleteConfirmation,
                    chart: chart,
                    onConfirm: {
                        viewModel.deleteChart(chart)
                        chartToDelete = nil
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func chartCard(for chart: ChartDefinition) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                HStack {
                    Text(chart.title)
                        .font(theme.typography.cardTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    // Menu button
                    Button(action: {
                        contextMenuChart = chart
                        showingContextMenu = true
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.colors.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(theme.colors.surfaceSecondary)
                            )
                    }
                    .buttonStyle(.plain)
                }

                // Chart content based on type and data
                chartContent(for: chart)
            }
        }
        .overlay(alignment: .topTrailing) {
            // Custom context menu
            if showingContextMenu && contextMenuChart?.id == chart.id {
                ChartContextMenu(
                    chart: chart,
                    onEdit: {
                        editingChart = chart
                        showingChartEditor = true
                    },
                    onDuplicate: {
                        viewModel.duplicateChart(chart)
                    },
                    onDelete: {
                        chartToDelete = chart
                        showingDeleteConfirmation = true
                    },
                    isPresented: $showingContextMenu
                )
                .offset(x: -8, y: 40)
                .zIndex(100)
            }
        }
        .onTapGesture(count: 1) { location in
            // Detect right-click (secondary button)
        }
        .gesture(
            TapGesture()
                .modifiers(.option)  // Right-click on macOS
                .onEnded {
                    contextMenuChart = chart
                    showingContextMenu = true
                }
        )
        .frame(minHeight: 320)
    }

    @ViewBuilder
    private func chartContent(for chart: ChartDefinition) -> some View {
        // For now, show empty states since we don't have real data yet
        // In production, this would check actual data arrays based on chart.dataSource
        let hasData = false

        if hasData {
            // Real chart rendering would go here
            Text("Chart rendering placeholder")
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 250)
        } else {
            // Empty State
            VStack(spacing: theme.spacing.m) {
                Image(systemName: chart.chartType.icon)
                    .font(.system(size: 48))
                    .foregroundColor(theme.colors.textSecondary)

                Text("No data for this configuration yet")
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textPrimary)

                Text("Configure the chart or add data to see results.")
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 250)
        }
    }
}
