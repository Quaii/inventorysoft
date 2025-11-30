import Charts
import SwiftUI

/// A unified chart component that can render different types of charts
struct AppChart: View {
    let title: String
    let chartType: ChartType
    let data: [Any]
    let valueFormatter: (Double) -> String

    @Environment(\.theme) var theme

    init(
        title: String,
        chartType: ChartType,
        data: [Any],
        valueFormatter: @escaping (Double) -> String = { "\($0)" }
    ) {
        self.title = title
        self.chartType = chartType
        self.data = data
        self.valueFormatter = valueFormatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.s) {
            Text(title)
                .font(theme.typography.cardTitle)
                .foregroundColor(theme.colors.textPrimary)

            if data.isEmpty {
                emptyState
            } else {
                chartContent
            }
        }
        .padding(theme.spacing.m)
        .background(theme.colors.surfacePrimary)
        .cornerRadius(theme.radii.card)
    }

    @ViewBuilder
    private var chartContent: some View {
        switch chartType {
        case .bar:
            Chart {
                ForEach(data.indices, id: \.self) { index in
                    if let point = data[index] as? ChartDataPoint {
                        BarMark(
                            x: .value("Category", point.label),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(theme.colors.accentSecondary)
                    }
                }
            }
        case .line:
            Chart {
                ForEach(data.indices, id: \.self) { index in
                    if let point = data[index] as? ChartDataPoint {
                        LineMark(
                            x: .value("Category", point.label),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(theme.colors.accentSecondary)
                    }
                }
            }
        case .area:
            Chart {
                ForEach(data.indices, id: \.self) { index in
                    if let point = data[index] as? ChartDataPoint {
                        AreaMark(
                            x: .value("Category", point.label),
                            y: .value("Value", point.value)
                        )
                        .foregroundStyle(theme.colors.accentSecondary.opacity(0.5))
                    }
                }
            }
        case .donut:
            Chart {
                ForEach(data.indices, id: \.self) { index in
                    if let point = data[index] as? ChartDataPoint {
                        SectorMark(
                            angle: .value("Value", point.value),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", point.label))
                    }
                }
            }
        case .table:
            // Simple table implementation
            VStack(spacing: 0) {
                ForEach(data.indices, id: \.self) { index in
                    if let point = data[index] as? ChartDataPoint {
                        HStack {
                            Text(point.label)
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.textPrimary)
                            Spacer()
                            Text(valueFormatter(point.value))
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                        .padding(.vertical, theme.spacing.xs)

                        if index < data.count - 1 {
                            Divider().background(theme.colors.borderSubtle)
                        }
                    }
                }
            }
        case .none:
            emptyState
        }
    }

    private var emptyState: some View {
        VStack {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 32))
                .foregroundColor(theme.colors.textSecondary.opacity(0.5))
            Text("No data available")
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(theme.colors.surfaceSecondary.opacity(0.5))
        .cornerRadius(theme.radii.medium)
    }
}

/// Protocol for data points used in AppChart
protocol ChartDataPoint {
    var label: String { get }
    var value: Double { get }
}

/// Concrete implementation for simple data points
struct SimpleChartDataPoint: ChartDataPoint, Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

// MARK: - Model Conformance

extension SalesDataPoint: ChartDataPoint {
    var label: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    var value: Double {
        return amount
    }
}

extension CategoryDataPoint: ChartDataPoint {
    var label: String {
        return category
    }

    var value: Double {
        return amount
    }
}

extension TopProductInfo: ChartDataPoint {
    var label: String {
        return name
    }

    var value: Double {
        return revenue
    }
}
