import SwiftUI

/// Content view for KPI (Key Performance Indicator) widgets
///
/// Displays a single metric value with optional secondary text and change indicator.
/// Renders with the same visual styling as the existing KPICard component but
/// adapted for widget embedding.
struct KPIWidgetContent: View {
    @Environment(\.theme) var theme
    let kpi: DashboardKPI
    let isLoading: Bool

    init(kpi: DashboardKPI, isLoading: Bool = false) {
        self.kpi = kpi
        self.isLoading = isLoading
    }

    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Image(systemName: kpi.metricKey.icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)

            // Value
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Text(kpi.value)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            // Secondary Text
            if let secondaryText = kpi.secondaryText {
                Text(secondaryText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}

/// Empty/Loading state for KPI widgets
struct KPIWidgetEmptyState: View {
    @Environment(\.theme) var theme
    let metricType: KPIMetricType

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: metricType.icon)
                .font(.system(size: 24))
                .foregroundColor(.secondary.opacity(0.3))

            Text("--")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.secondary)

            Text("Loading...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}
