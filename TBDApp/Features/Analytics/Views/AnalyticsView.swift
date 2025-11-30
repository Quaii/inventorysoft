import Charts
import SwiftUI

struct AnalyticsView: View {
    @StateObject var viewModel: AnalyticsViewModel
    @Environment(\.theme) var theme
    @State private var timeRange: String = "Last 30 Days"

    // Configuration sheets
    @State private var editingChart: ChartDefinition?
    @State private var showingMetricConfig = false
    @State private var showingFormulaConfig = false
    @State private var showingColorConfig = false
    @State private var showingDeleteConfirmation = false
    @State private var chartToDelete: ChartDefinition?
    @State private var showingAddChartSheet = false

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
                            showingAddChartSheet = true
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
                            showingAddChartSheet = true
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
        .sheet(isPresented: $showingMetricConfig) {
            if let chartIndex = viewModel.charts.firstIndex(where: { $0.id == editingChart?.id }),
                editingChart != nil
            {
                ChartMetricConfigView(chartDefinition: $viewModel.charts[chartIndex])
                    .onDisappear {
                        if let updatedChart = viewModel.charts.first(where: {
                            $0.id == editingChart?.id
                        }) {
                            viewModel.updateChart(updatedChart)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingFormulaConfig) {
            if let chartIndex = viewModel.charts.firstIndex(where: { $0.id == editingChart?.id }),
                editingChart != nil
            {
                ChartFormulaConfigView(formula: $viewModel.charts[chartIndex].formula)
                    .onDisappear {
                        if let updatedChart = viewModel.charts.first(where: {
                            $0.id == editingChart?.id
                        }) {
                            viewModel.updateChart(updatedChart)
                        }
                    }
            }
        }
        .sheet(isPresented: $showingColorConfig) {
            if let chartIndex = viewModel.charts.firstIndex(where: { $0.id == editingChart?.id }),
                editingChart != nil
            {
                ChartColorConfigView(colorPalette: $viewModel.charts[chartIndex].colorPalette)
                    .onDisappear {
                        if let updatedChart = viewModel.charts.first(where: {
                            $0.id == editingChart?.id
                        }) {
                            viewModel.updateChart(updatedChart)
                        }
                    }
            }
        }
        .alert("Delete Chart", isPresented: $showingDeleteConfirmation, presenting: chartToDelete) {
            chart in
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteChart(chart)
            }
        } message: { chart in
            Text("Are you sure you want to delete '\(chart.title)'? This action cannot be undone.")
        }
        .sheet(isPresented: $showingAddChartSheet) {
            // Simple sheet to choose a starting point
            VStack(spacing: theme.spacing.l) {
                Text("Add New Chart")
                    .font(theme.typography.sectionTitle)

                Button("Revenue Trend") {
                    viewModel.addChart(.revenueTrend)
                    showingAddChartSheet = false
                }

                Button("Sales by Category") {
                    viewModel.addChart(.salesByCategory)
                    showingAddChartSheet = false
                }

                Button("Top Products") {
                    viewModel.addChart(.topProducts)
                    showingAddChartSheet = false
                }

                Button("Cancel", role: .cancel) {
                    showingAddChartSheet = false
                }
                .padding(.top)
            }
            .padding()
            .presentationDetents([.medium])
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

                    // Chart type indicator
                    Image(systemName: chart.chartType.icon)
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.textSecondary)
                }

                // Chart content based on type and data
                chartContent(for: chart)
            }
        }
        .contextMenu {
            // Change Chart Type submenu
            Menu("Change Chart Type") {
                ForEach([ChartType.bar, .line, .area, .donut, .table], id: \.self) { type in
                    Button(action: {
                        var updatedChart = chart
                        updatedChart.chartType = type
                        viewModel.updateChart(updatedChart)
                    }) {
                        Label(type.displayName, systemImage: type.icon)
                    }
                }
            }

            Divider()

            Button(action: {
                editingChart = chart
                showingMetricConfig = true
            }) {
                Label("Change Metric…", systemImage: "slider.horizontal.3")
            }

            Button(action: {
                editingChart = chart
                showingFormulaConfig = true
            }) {
                Label("Custom Formula…", systemImage: "function")
            }

            Button(action: {
                editingChart = chart
                showingColorConfig = true
            }) {
                Label("Change Colors…", systemImage: "paintpalette")
            }

            Divider()

            Button(action: {
                viewModel.duplicateChart(chart)
            }) {
                Label("Duplicate Chart", systemImage: "doc.on.doc")
            }

            Button(
                role: .destructive,
                action: {
                    chartToDelete = chart
                    showingDeleteConfirmation = true
                }
            ) {
                Label("Remove Chart", systemImage: "trash")
            }
        }
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
