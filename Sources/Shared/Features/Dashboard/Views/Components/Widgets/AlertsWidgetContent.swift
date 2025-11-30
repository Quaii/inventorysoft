import SwiftUI

/// Content view for priority alerts widget
///
/// Displays a list of active alerts with dismiss functionality.
/// Reuses the AlertChip component for individual alert rendering.
struct AlertsWidgetContent: View {
    @Environment(\.theme) var theme
    let alerts: [DashboardAlert]
    let onDismiss: (DashboardAlert) -> Void

    var activeAlerts: [DashboardAlert] {
        alerts.filter { !$0.isDismissed }
    }

    init(
        alerts: [DashboardAlert],
        onDismiss: @escaping (DashboardAlert) -> Void = { _ in }
    ) {
        self.alerts = alerts
        self.onDismiss = onDismiss
    }

    var body: some View {
        if activeAlerts.isEmpty {
            AlertsEmptyState()
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: theme.spacing.s) {
                    ForEach(activeAlerts) { alert in
                        AlertChip(
                            alert: alert,
                            onDismiss: {
                                onDismiss(alert)
                            }
                        )
                    }
                }
                .padding(theme.spacing.m)
            }
        }
    }
}

/// Empty state for alerts widget
struct AlertsEmptyState: View {
    @Environment(\.theme) var theme

    var body: some View {
        VStack(spacing: theme.spacing.m) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 32))
                .foregroundColor(theme.colors.success)

            Text("All clear!")
                .font(theme.typography.sectionTitle)
                .foregroundColor(theme.colors.textPrimary)

            Text("No active alerts at this time")
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(theme.spacing.xl)
    }
}
