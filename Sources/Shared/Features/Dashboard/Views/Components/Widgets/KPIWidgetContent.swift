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
        VStack(spacing: theme.spacing.s) {
            // Icon
            Image(systemName: kpi.metricKey.icon)
                .font(.system(size: 24))
                .foregroundColor(theme.colors.accentSecondary)

            // Value
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Text(kpi.value)
                    .font(theme.typography.pageTitle)
                    .fontWeight(.bold)
                    .foregroundColor(theme.colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            // Secondary Text
            if let secondaryText = kpi.secondaryText {
                Text(secondaryText)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(theme.spacing.m)
    }
}

/// Empty/Loading state for KPI widgets
struct KPIWidgetEmptyState: View {
    @Environment(\.theme) var theme
    let metricType: KPIMetricType

    var body: some View {
        VStack(spacing: theme.spacing.s) {
            Image(systemName: metricType.icon)
                .font(.system(size: 24))
                .foregroundColor(theme.colors.textSecondary.opacity(0.3))

            Text("--")
                .font(theme.typography.pageTitle)
                .fontWeight(.bold)
                .foregroundColor(theme.colors.textSecondary)

            Text("Loading...")
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(theme.spacing.m)
    }
}
