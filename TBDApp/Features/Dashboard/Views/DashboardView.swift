import Charts
import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.xl) {
                // Header
                HStack {
                    Text("Dashboard")
                        .font(theme.typography.headingXL)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    AppButton(title: "Refresh", icon: "arrow.clockwise", style: .secondary) {
                        Task { await viewModel.loadMetrics() }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(theme.colors.error)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: theme.spacing.xl) {
                            // KPI Grid
                            LazyVGrid(
                                columns: [
                                    GridItem(.adaptive(minimum: 240), spacing: theme.spacing.l)
                                ], spacing: theme.spacing.l
                            ) {
                                kpiCard(
                                    title: "Inventory Value",
                                    value: viewModel.totalInventoryValue.formatted(
                                        .currency(code: "USD")), icon: "dollarsign.circle.fill",
                                    color: theme.colors.accentPrimary)
                                kpiCard(
                                    title: "Total Sales",
                                    value: viewModel.totalSalesRevenue.formatted(
                                        .currency(code: "USD")), icon: "chart.line.uptrend.xyaxis",
                                    color: theme.colors.success)
                                kpiCard(
                                    title: "Net Profit",
                                    value: viewModel.totalNetProfit.formatted(
                                        .currency(code: "USD")), icon: "banknote.fill",
                                    color: theme.colors.accentSecondary)
                                kpiCard(
                                    title: "Items in Stock", value: "\(viewModel.itemCount)",
                                    icon: "cube.box.fill", color: theme.colors.warning)
                            }

                            // Charts Section
                            AppCard {
                                VStack(alignment: .leading, spacing: theme.spacing.m) {
                                    Text("Sales Trend (Last 7 Days)")
                                        .font(theme.typography.headingM)
                                        .foregroundColor(theme.colors.textPrimary)

                                    if viewModel.salesChartData.isEmpty {
                                        Text("No sales data available.")
                                            .font(theme.typography.bodyM)
                                            .foregroundColor(theme.colors.textSecondary)
                                            .frame(height: 200)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    } else {
                                        AppChart(data: viewModel.salesChartData)
                                    }
                                }
                            }

                            // Secondary Section
                            HStack(alignment: .top, spacing: theme.spacing.l) {
                                RecentActivityView(activities: viewModel.recentActivity)
                                StockAlertsView(items: viewModel.stockAlerts)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadMetrics()
        }
    }

    private func kpiCard(title: String, value: String, icon: String, color: Color) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(theme.typography.headingM)
                    Spacer()
                    // Trend indicator could go here
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(value)
                        .font(theme.typography.numericEmphasis)
                        .foregroundColor(theme.colors.textPrimary)
                    Text(title)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.s) {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
                Text(value)
                    .font(theme.typography.h2)
                    .foregroundColor(theme.colors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct RecentActivityView: View {
    let activities: [ActivityItem]
    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                Text("Recent Activity")
                    .font(theme.typography.headingM)
                    .foregroundColor(theme.colors.textPrimary)

                if activities.isEmpty {
                    Text("No recent activity to show.")
                        .font(theme.typography.bodyM)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, theme.spacing.xl)
                } else {
                    VStack(spacing: 0) {
                        Text("Activities: \(activities.count)")
                        // ForEach removed for debugging
                    }
                }
            }
        }
    }
}

struct StockAlertsView: View {
    let items: [Item]
    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                HStack {
                    Text("Stock Alerts")
                        .font(theme.typography.headingM)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    if !items.isEmpty {
                        Text("\(items.count) items low")
                            .font(theme.typography.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.colors.error.opacity(0.1))
                            .foregroundColor(theme.colors.error)
                            .cornerRadius(4)
                    }
                }

                if items.isEmpty {
                    Text("All items are well stocked.")
                        .font(theme.typography.bodyM)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, theme.spacing.xl)
                } else {
                    VStack(spacing: 0) {
                        Text("Items: \(items.count)")
                        // ForEach removed for debugging
                    }
                }
            }
        }
    }
}

struct AppChart: View {
    let data: [SalesDataPoint]
    @Environment(\.theme) var theme

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Sales", point.amount)
            )
            .foregroundStyle(theme.colors.accentPrimary)
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value("Date", point.date, unit: .day),
                y: .value("Sales", point.amount)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        theme.colors.accentPrimary.opacity(0.3),
                        theme.colors.accentPrimary.opacity(0.0),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                    .foregroundStyle(theme.colors.borderSubtle)
                AxisValueLabel()
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .frame(height: 200)
    }
}
