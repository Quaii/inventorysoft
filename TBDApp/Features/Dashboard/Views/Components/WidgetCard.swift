import Charts
import SwiftUI

struct WidgetCard: View {
    let widget: DashboardWidget
    let data: WidgetData
    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                // Header
                HStack {
                    Image(systemName: widget.type.icon)
                        .foregroundColor(theme.colors.accentPrimary)
                        .font(.system(size: 20))

                    Text(widget.metric.displayName)
                        .font(theme.typography.cardTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()
                }

                // Content based on widget type
                switch widget.type {
                case .stat:
                    kpiContent
                case .chart:
                    chartContent
                case .list:
                    listContent
                case .text, .alert:
                    textContent
                }
            }
        }
        .frame(height: heightForSize(widget.size))
    }

    @ViewBuilder
    private var kpiContent: some View {
        if let value = data.kpiValue {
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(theme.typography.headingL)
                    .foregroundColor(theme.colors.textPrimary)

                if let trend = data.trendPercentage {
                    Text(trend)
                        .font(theme.typography.caption)
                        .foregroundColor(
                            trend.hasPrefix("+") ? theme.colors.success : theme.colors.error
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            (trend.hasPrefix("+") ? theme.colors.success : theme.colors.error)
                                .opacity(0.1)
                        )
                        .cornerRadius(4)
                }
            }
        }
    }

    @ViewBuilder
    private var chartContent: some View {
        if let chartData = data.chartData {
            Chart(chartData) { point in
                switch widget.chartType ?? .none {
                case .bar:
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(theme.colors.accentPrimary)
                    .cornerRadius(4)
                case .line:
                    LineMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(theme.colors.accentPrimary)
                case .area:
                    AreaMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(theme.colors.accentPrimary.opacity(0.3))
                case .donut, .table, .none:
                    BarMark(
                        x: .value("Date", point.date, unit: .day),
                        y: .value("Value", point.value)
                    )
                    .foregroundStyle(theme.colors.accentPrimary)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                        .foregroundStyle(theme.colors.borderSubtle)
                }
            }
            .frame(height: 200)
        }
    }

    @ViewBuilder
    private var listContent: some View {
        if let items = data.listItems {
            VStack(spacing: 0) {
                ForEach(items.prefix(5)) { item in
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundColor(item.iconColor)
                            .frame(width: 32, height: 32)
                            .background(theme.colors.surfaceElevated)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.textPrimary)
                            Text(item.subtitle)
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        }

                        Spacer()

                        Text(item.timestamp)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                    .padding(.vertical, 12)

                    if item.id != items.prefix(5).last?.id {
                        Divider().overlay(theme.colors.borderSubtle)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var textContent: some View {
        if let text = data.textValue {
            Text(text)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
        }
    }

    private func heightForSize(_ size: WidgetSize) -> CGFloat {
        switch size {
        case .small: return 140
        case .medium: return 300
        case .large: return 400
        }
    }
}

// Data model for widget content
struct WidgetData {
    var kpiValue: String?
    var trendPercentage: String?
    var chartData: [ChartDataPoint]?
    var listItems: [ListItem]?
    var textValue: String?

    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    struct ListItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let iconColor: Color
        let timestamp: String
    }
}
