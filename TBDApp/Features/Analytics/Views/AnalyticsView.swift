import Charts
import SwiftUI

struct AnalyticsView: View {
    @Environment(\.theme) var theme
    @State private var timeRange: String = "Last 30 Days"

    // TODO: Connect to AnalyticsViewModel for real data
    @State private var salesData: [SalesDataPoint] = []
    @State private var categoryData: [CategoryDataPoint] = []
    @State private var topProducts: [TopProductInfo] = []

    var body: some View {
        AppScreenContainer {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Analytics",
                    title: "Analytics",
                    subtitle: "Deep dive into your business metrics"
                ) {
                    AppDropdown(
                        options: ["Last 7 Days", "Last 30 Days", "This Year"],
                        selection: $timeRange
                    )
                    .frame(width: 160)
                }

                // Content
                VStack(alignment: .leading, spacing: theme.spacing.xl) {
                    // Revenue Trend
                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.m) {
                            HStack {
                                Text("Revenue Trend")
                                    .font(theme.typography.cardTitle)
                                    .foregroundColor(theme.colors.textPrimary)

                                Spacer()
                            }

                            if salesData.isEmpty {
                                // Empty State
                                VStack(spacing: theme.spacing.m) {
                                    Image(systemName: "chart.bar")
                                        .font(.system(size: 48))
                                        .foregroundColor(theme.colors.textSecondary)

                                    Text("No sales data yet")
                                        .font(theme.typography.sectionTitle)
                                        .foregroundColor(theme.colors.textPrimary)

                                    Text("Record your first sale to see revenue trends here.")
                                        .font(theme.typography.body)
                                        .foregroundColor(theme.colors.textSecondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                            } else {
                                Chart(salesData) { point in
                                    BarMark(
                                        x: .value("Date", point.date, unit: .day),
                                        y: .value("Sales", point.amount)
                                    )
                                    .foregroundStyle(theme.colors.accentPrimary)
                                    .cornerRadius(4)
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
                                .frame(height: 250)
                            }
                        }
                    }
                    .frame(minHeight: 280)

                    // Bottom Row: Category Breakdown + Top Products
                    HStack(alignment: .top, spacing: theme.spacing.xl) {
                        // Sales by Category
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.m) {
                                Text("Sales by Category")
                                    .font(theme.typography.cardTitle)
                                    .foregroundColor(theme.colors.textPrimary)

                                if categoryData.isEmpty {
                                    // Empty State
                                    VStack(spacing: theme.spacing.m) {
                                        Image(systemName: "chart.pie")
                                            .font(.system(size: 48))
                                            .foregroundColor(theme.colors.textSecondary)

                                        Text("No category data")
                                            .font(theme.typography.body)
                                            .foregroundColor(theme.colors.textPrimary)

                                        Text("Sales will be categorized here.")
                                            .font(theme.typography.caption)
                                            .foregroundColor(theme.colors.textSecondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 250)
                                } else {
                                    Chart(categoryData) { point in
                                        SectorMark(
                                            angle: .value("Sales", point.value),
                                            innerRadius: .ratio(0.6),
                                            angularInset: 2
                                        )
                                        .foregroundStyle(by: .value("Category", point.category))
                                        .cornerRadius(4)
                                    }
                                    .frame(height: 250)
                                    .chartLegend(position: .bottom, spacing: 16)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 320)

                        // Top Products List
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.m) {
                                Text("Top Products")
                                    .font(theme.typography.cardTitle)
                                    .foregroundColor(theme.colors.textPrimary)

                                if topProducts.isEmpty {
                                    // Empty State
                                    VStack(spacing: theme.spacing.m) {
                                        Image(systemName: "star")
                                            .font(.system(size: 48))
                                            .foregroundColor(theme.colors.textSecondary)

                                        Text("No products yet")
                                            .font(theme.typography.body)
                                            .foregroundColor(theme.colors.textPrimary)

                                        Text("Top-selling products will appear here.")
                                            .font(theme.typography.caption)
                                            .foregroundColor(theme.colors.textSecondary)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 250)
                                } else {
                                    VStack(spacing: theme.spacing.s) {
                                        ForEach(Array(topProducts.enumerated()), id: \.element.id) {
                                            index, product in
                                            HStack {
                                                Text("#\(index + 1)")
                                                    .font(theme.typography.caption)
                                                    .foregroundColor(theme.colors.textSecondary)
                                                    .frame(width: 24)

                                                Text(product.name)
                                                    .font(theme.typography.body)
                                                    .foregroundColor(theme.colors.textPrimary)

                                                Spacer()

                                                Text(
                                                    product.revenue.formatted(
                                                        .currency(code: "USD"))
                                                )
                                                .font(theme.typography.body)
                                                .foregroundColor(theme.colors.textPrimary)
                                            }
                                            .padding(.vertical, 4)

                                            if index < topProducts.count - 1 {
                                                Divider().overlay(theme.colors.borderSubtle)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 320)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

struct CategoryDataPoint: Identifiable {
    let id = UUID()
    let category: String
    let value: Double
}

struct TopProductInfo: Identifiable {
    let id = UUID()
    let name: String
    let revenue: Double
}
