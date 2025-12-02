import Charts
import GRDB
import SwiftUI

/// Renders chart content based on widget configuration
///
/// This component is used by the unified widget grid to display chart widgets
/// on both the Dashboard and Analytics pages.
struct ChartWidgetContent: View {

    let widget: UserWidget
    let salesData: [SalesDataPoint]
    let isLoading: Bool

    init(widget: UserWidget, salesData: [SalesDataPoint] = [], isLoading: Bool = false) {
        self.widget = widget
        self.salesData = salesData
        self.isLoading = isLoading
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Chart visualization
            if let config: ChartWidgetConfig = widget.getConfiguration() {
                chartView(for: config)
            } else {
                // Fallback for widgets without configuration
                defaultChartView()
            }
        }
    }

    @ViewBuilder
    private func chartView(for config: ChartWidgetConfig) -> some View {
        // Check if we have data
        let hasData = !salesData.isEmpty

        if hasData {
            // Render actual chart based on type and metric
            switch config.chartType {
            case .line:
                lineChartView(config: config)
            case .bar:
                barChartView(config: config)
            case .donut:
                donutChartView(config: config)
            default:
                lineChartView(config: config)  // Default to line
            }
        } else {
            emptyStateView()
        }
    }

    @ViewBuilder
    private func defaultChartView() -> some View {
        // Simple chart view when no configuration exists
        if !salesData.isEmpty {
            lineChartView(config: ChartWidgetConfig.default)
        } else {
            emptyStateView()
        }
    }

    // MARK: - Chart Type Views

    @ViewBuilder
    private func lineChartView(config: ChartWidgetConfig) -> some View {
        Chart(salesData) { dataPoint in
            LineMark(
                x: .value("Date", dataPoint.date),
                y: .value("Amount", dataPoint.amount)
            )
            .foregroundStyle(.blue)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(formatCurrency(doubleValue))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(height: 280)
    }

    @ViewBuilder
    private func barChartView(config: ChartWidgetConfig) -> some View {
        Chart(salesData) { dataPoint in
            BarMark(
                x: .value("Date", dataPoint.date),
                y: .value("Amount", dataPoint.amount)
            )
            .foregroundStyle(.blue)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(formatCurrency(doubleValue))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(height: 280)
    }

    @ViewBuilder
    private func donutChartView(config: ChartWidgetConfig) -> some View {
        // Aggregate data for pie/donut chart
        let total = salesData.reduce(0) { $0 + $1.amount }

        if total > 0 {
            Chart(salesData.prefix(5)) { dataPoint in
                SectorMark(
                    angle: .value("Amount", dataPoint.amount),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(
                    by: .value("Date", dataPoint.date.formatted(date: .abbreviated, time: .omitted))
                )
            }
            .frame(height: 280)
        } else {
            emptyStateView()
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private func emptyStateView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: widget.type.icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("No data available")
                .font(.body)
                .foregroundColor(.primary)

            Text("Configure the chart or add data to see results.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
    }

    // MARK: - Helper Methods

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}
// MARK: - Preview

#if DEBUG
    struct ChartWidgetContent_Previews: PreviewProvider {
        static var previews: some View {
            ChartWidgetContent(
                widget: UserWidget(
                    type: .revenueChart,
                    size: .large,
                    name: "Revenue Trend",
                    position: 0
                )
            )
            .environmentObject(
                AnalyticsViewModel(
                    widgetRepository: AnalyticsWidgetRepository(),
                    analyticsService: AnalyticsService(
                        itemRepository: ItemRepository(),
                        salesRepository: SalesRepository()
                    ),
                    configService: AnalyticsConfigService(
                        repository: AnalyticsConfigRepository(
                            dbQueue: DatabaseManager.shared.dbWriter as! GRDB.DatabaseQueue),
                        preferencesRepo: UserPreferencesRepository()
                    ),
                    exportService: ExportService(
                        db: DatabaseManager.shared,
                        columnConfigService: ColumnConfigService(
                            repository: ColumnConfigRepository())
                    )
                )
            )

            .frame(width: 400, height: 350)
            .padding()
        }
    }
#endif
